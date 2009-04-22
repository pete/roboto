; An small geometry library, actually cut out of the test suite for
; curry/compose.
(= pkgname 'Geometry)

(= square-all (curry map ^2))
(= sum-of-squares (compose sum square-all))
(= hypoteneuse (compose sqrt sum-of-squares))
(def point-to-point (point-a point-b)
     (hypoteneuse (map (\ p -> apply - p) (zip point-a point-b))))
