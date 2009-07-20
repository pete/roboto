; A counter calls a function every n times that it is called.  It returns the
; result of that function when performed, and nil otherwise.
(= pkgname 'Counter)

(def new (n f)
     (bind (i 0)
         (\ -> do 
               (+= i 1)
               (when (== n i) (= i 0) (f)))))
