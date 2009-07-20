(= pkgname 'OS)

(def waitpid (pid options)
     (bind ((pstatus (C 'malloc 4))  ; TODO:  sizeof(int)
            (p nil)
            (status nil)
            )
           (= p (C 'waitpid pid pstatus options))
           (= status (deref-as 'int pstatus 4))
           (C 'free pstatus)
           (list p status)))

(shadow 'uid)
(= uid (C 'getuid))
