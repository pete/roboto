; Just for fun, here are some combinators in Roboto.
; id and v are defined in core.rl, and in a more straightforward way for this
; language.

(= pkgname 'SKI)

; Prelude:
(= λ lambda) ; A more classical feel.

; The two primitives:
(def S x (λ y (λ z ((x z) (y z)))))
(def K x (λ y x))
; There are zero lambdas below this line:

(= V (((S ((S (K S)) K)) K)((S ((S (K S)) K)) K)))
(= I ((S K) K))
(= Y (((S (K ((S I) I))) (S ((S (K S)) K))) (K ((S I) I))))
