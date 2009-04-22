(= pkgname 'Cynara)

(import 'dl)

(merge! binding (bind (
                       (running-program (dl 'open' null-pointer (dl 'lazy)))
                       (decls (bind))
                       ; Technical difficulties using magic to get the page
                       ; size:
                       ;(page-size (C '(sysconf _SC_PAGESIZE)))
                       (page-size 0x1000) ; It's usually 4k.
                       )))

; TODO:  There should be a way to find this out, worst case is parsing header
; files.  It's a little too 2 a.m. for that, though.
(def declare (rval name arglist)
     (decls 'shadow name)
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
             (and (list? obj) (== (obj 0) 'literal))
                (= c-line ((. to-s obj) 1))
                
             (list? obj) (do
                 (each (\ a -> do
                              (= a (pseudo-c-line a))
                              (append! c-line (a 0))
                              (concat! needed-syms (a 1))) 
                       obj)
                 (= c-line (sprintf "%s(%s)" 
                                    (c-line 0) (join ", " (cdr c-line)))))

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
     (= ls (pseudo-c-lines ls))
     (= (lines syms) ls)
     (uniq! syms)
     (-= syms '(return ? : if else))
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
