; Roboto-FFI!

(= LibM
   (ffi-bind '("m") '("math.h")
             (pi (ffi-const 'double 'M_PI))
             (sin (ffi-func 'double 'sin '(double)))))
(LibM '(do 
         (= epsilon 0.000001)
         (def within-epsilon (a b) 
              (< (- epsilon) (- a b) epsilon))))

(puts "(FFI!)")
(test "sin(π/2) is 1 (libc precision aside...)"
      (LibM '(within-epsilon 1 (sin (/ pi 2)))))
