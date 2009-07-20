; This is the standard high-level I/O library; it depends on all underlying C
; syscalls, but not so much C's stdio.  Ruby's suite of I/O
; functions/classes/methods are so nice that I will probably dup most of them.
(= File (bind ()
    (= chunk-size 0x1000) ; 4kb, the amount we read at a time.

    ; Reads a whole file, returning nil if it fails
    (def read fname
            (bind ((fd nil) (contents "") (last-read nil) (nbytes 0) 
                   (eof? false) (p nil))

                  (= fd (C 'open (to-s fname) 0 0))
                  (= p (C 'malloc chunk-size))
                  (when (! p) (fatal! "Out of memory?  Malloc failed."))

                  (if (< fd 0) false 
                    (do 
                      (while (! eof?)
                             (= nbytes (C 'read fd p chunk-size))
                             (= last-read (deref-as 'string p nbytes))
                             (append! contents last-read)
                             (= eof? (== nbytes 0)))
                      (C 'free p)
                      (C 'close fd)
                      contents))))

    ; Reads a whole file and returns a list with one entry for each line in the
    ; file.
    (def readlines fname
         (bind (contents (read fname))
               (if contents (split [\r?\n] contents))))

    ; Writes a big-ass string to a file.
    (def write (fname contents) 
         (bind (fd (C 'open fname (b| (C 'O_WRONLY) (C 'O_CREAT)) 0o666))
                (if (< fd 0) nil
                  (do' (C 'write fd contents (len contents)) (C 'close fd)))))
    
    (def append (fname contents)
         (bind (fd (C 'open fname (C '(b| O_WRONLY O_APPEND O_CREAT)) 0o666))
               (if (< fd 0) nil
                 (do' (C 'write fd contents (len contents)) (C 'close fd)))))

    (def exist? fname
         (to-bool (C 'fstat fname)))

    binding))
