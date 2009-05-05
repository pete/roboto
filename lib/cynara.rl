; Cynara, Roboto's dynamic C library.  It is sort of ugly (but working) for the
; time being, but the eventual goal is to build it to the point that it can
; compile lambdas, at which point Roboto can have a compiler and I can begin the
; process of rewriting Roboto in Roboto.  There are a few things that need to be
; done before Roboto will be grown up enough for this, some of them trivial,
; some not so much:
;   1.  Better Hash support.  (This will improve a number of things in Roboto.)
;   2.  Better support for C structs (which Cynara is being used to bootstrap).
;   3.  Not using the __robogenerated__ name for every generated function.
;   4.  Producing more things at intermediate steps, and remembering more about
;   the code that is generated, to make the compiler more flexible.
;   5.  Decoupling of the running image from the generated C code.  This will be
;   done by fixing up the handling of literals (which work the way they do
;   because it is difficult to portably dump the text/data sections by name and
;   load them at arbitrary addresses; this amounts to doing manual linking), and
;   creating a flag for whether to generate the literals and prepend addresses
;   as #defines or to add a #include to the C file.  (Depends on #4.)
;   6.  Fixing hacks, leaks, and ad-hockery in the below code.
;   7.  Smarter handling of the environment so that the C compiler, CFLAGS,
;   etc., are not all hard-coded.
;   8.  Creating a faster pipeline.  This is mostly a task of digging through
;   compiler man-pages and/or combing the mailing lists (and answering the "Why
;   would you want to do *that*?" question a few times, I'm sure), which is
;   tedious rather than hard.  (For example, it is pretty simple to get the
;   compiler to accept stdin for the source code, but I am not sure how to do
;   the same for its binary output or how to tell objcopy to read/write
;   stdin/stdout.)
;   9.  Finalizing the Roboto function-calling semantics (which will probably
;   require rewriting some of lib/core.rl), and probably making macros into a
;   compile-time feature rather than run-time feature (which, again, will
;   involve some rewriting).
; That they are numbered isn't meant to imply an order.
(= pkgname 'Cynara)

(import 'dl)

(merge! binding (bind (
                       (running-program (dl 'open' null-pointer (dl 'lazy)))
                       (decls (bind (sigs ())))
                       ; Technical difficulties using magic to get the page
                       ; size:
                       ;(page-size (C '(sysconf _SC_PAGESIZE)))
                       (page-size 0x1000) ; It's usually 4k.
                       )))

; TODO:  There should be a way to find this out, worst case is parsing header
; files.  It's a little too 2 a.m. for that, though.
(def declare (rval name arglist)
     (decls 'shadow name)
	 (append! (decls 'sigs) (list rval name arglist))
     (decls 'set name
            (sprintf "((%s (*)(%s))0x%x)"
                     (to-s rval)
                     (join ", " (map to-s arglist))
                     (sym->pointer name))))


(def syms->header syms
     (map (\ sym -> if (decls 'defined? sym)
                         (sprintf "#define %s %s\n"
                             (to-s sym)
                             (decls sym))
                       (sprintf "#error \"%s is not defined!\"" (to-s sym)))
          syms))

(def sym->pointer sym
     (dl 'sym running-program (to-s sym)))

(def pseudo-c-line obj
     (bind ((needed-syms ())
            (c-line ()))
           (if 
             (list? obj)
               (if (== (obj 0) 'literal) (= c-line ((. to-s obj) 1))
                   (== (obj 0) 'include) ()
                     (do 
                         (each (\ a -> do
                                    (= a (pseudo-c-line a))
                                    (append! c-line (a 0))
                                    (concat! needed-syms (a 1))) 
                               obj)
                         (= c-line (sprintf "%s(%s)" 
                                      (c-line 0) (join ", " (cdr c-line))))))

             (sym? obj) (do (= c-line (to-s obj)) 
                            (append! needed-syms obj))

             (string? obj) (do (= c-line (to-i (C 'strdup obj)));FIXME: leak
                             (when (zero? c-line) 
                               (fatal! (+ "Couldn't strdup " obj)))
                             (= c-line (sprintf "((char *)0x%x)" c-line)))

             (= c-line (inspect obj)))

           (list c-line (uniq! needed-syms))))

(def pseudo-c-lines lines
     (bind (a (list () ()))
           (each (\ line -> bind (r (pseudo-c-line line))
                         (append! (a 0) (sprintf "%s;\n" (r 0)))
                         (uniq! (concat! (a 1) (r 1))))
                 lines)
           a))

(def generate ls
     (shadow 'lines)
     (shadow 'syms)
     (= (lines syms) (pseudo-c-lines ls))
     (uniq! syms)
     ; There will have to be a list of reserved C words, either in or used by
     ; the header parser.  For now, this:
     (-= syms '(sizeof argv return ? : if else))
     (+ (sum (syms->header syms)) 
        "unsigned long int __robogenerated__(unsigned long int args)\n"
        "{\n"
        (sum lines)
        "}\n"))

(def compile s
     ; TODO:  Do this correctly, figure out the c compiler, where to put tmp
     ; files, proper flags, etc.
     (File 'write "/tmp/cynara-tmp.c" s)
     (and (sys "gcc -Os -c -fPIC /tmp/cynara-tmp.c -o /tmp/cynara-tmp.o")
          (sys (+ "objcopy -O binary -j .text /tmp/cynara-tmp.o "
                  "/tmp/cynara-tmp.bin"))))

(def call-by-address (addr *argv)
     (deref-obj (raw-call-by-address addr (ref-to argv))))

(def load-page fname
     (bind ((page ())
            (code-size ())
            (ptr ())
            (fd ())
            ; Disgusting hack around a temporary technical limitation, please
            ; ignore.
            ; ...
            ; ...story of my life.
            (fsize (len (File 'read fname)))
           )
           (= code-size (+ fsize (- page-size (% fsize page-size))))
           (= page (C 'memalign page-size code-size))
           (if (null-pointer? page) (fatal! "Couldn't allocate memory!"))
           (= fd (C 'open fname (C 'O_RDONLY) 0))
           (if (< fd 0) (fatal! "It's 2:41 a.m. and I'm not handling errors."))
           (C 'read fd page fsize)
           (C 'close fd)
           (C 'mprotect page code-size (C '(b| PROT_READ PROT_EXEC)))
           page))
