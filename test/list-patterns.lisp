; A thing:
'a
; Some things:
'*b
; A thing with criteria:
'(int? c)
; Some things with criteria:
'(int? *d)
; At least x things, no more than y things:
'(true *f (x y))
; Exactly x things:
'(true *g x)
; x to y things, with criteria:
'(int? *f (x y))
; A sub-pattern:
'(sub g (sub-pattern here)) ; g ends up with the binding.  Optional?
; x to y repetitions of the sub-pattern
'(sub *g (x y) (sub-pattern)) ; Not sure if this one makes sense.
; Back-reference to 'a:
'(back h 'a)
; A thing or another thing
'(or i '(sub-pattern) '(sub-pattern))
; One or more of the things may be supplied:
'(any (int? i) (string? s)) ; Matches if an int and/or a string are supplied,
                            ; in any order.  Stops when it gets both.  May be
                            ; possible to add with a combination of 'or and
                            ; back-references.

(puts "(Test list pattern-matching.  REVOLUTION!)")

(puts "Meet (lpm ...).")
;(setlog 0)
(= b (lpm '(a) '(1)))
(test "A simple binding creation via lpm:"
      (== 1 (b 'a)))

(= b (lpm '(a ... *b) '(1 2 3 4)))
(test "Using the black hole."
      (== '(1 (3 4)) (b '(list a b))))

(= b (lpm '(a 'b c) '(1 b 3)))
(test "Using a symbol literal, getting a match." b)
(test "Proper fill-in from that symbol literal."
      (and b (== '(1 3) (b '(list a c)))))

(= b (lpm '(a (int? b) c) '(1 2 3)))
(test "A type test on an item."
      (and b (== '(1 2 3) (b '(list a b c)))))
(= b (lpm '(a (int? b) c) '(a a a)))
(test "Negative match." (! b))

(= b (lpm '(a 
            ((op and (< it 4) (> it 1)) *b) 
            c) 
          '(1 2 3 4)))

(test "A test on multiple items."
      (and b (== '(2 3) (b 'b))))

(= b (lpm '(*a (id b) *c) (list nil nil nil 5 nil nil)))
(test "Find the five!  Proper branching!"
      (and b (== 5 (b 'b))))

(= b (lpm '(*a (id *b 5) *c) (list nil nil nil 5 6 7 8 'sym nil nil)))
(test "Find the five things that are not nil!  Proper branching!"
      (and b (== '(5 6 7 8 sym) (b 'b))))

(= b (lpm '(*a (id *b 5) *c) (list nil nil nil 5 6 7 8 nil nil)))
(test "Don't find the five things that are not nil if they aren't there!"
      (! b))

(= b (lpm '(*a (id *b 3) *c) (list nil nil nil 5 6 7 8 nil nil)))
(test "Matching is greedy."
      (and b (include? (b 'a) 5) (== '(6 7 8) (b 'b))))

(def f (*a (id *b 3) *c) b)
(= l (list nil nil nil 5 6 7 8 nil nil))
(test "The same, but with a lambda"
      (== '(6 7 8) (apply f l)))
(def f (*a (id b 3) *c) (list a b c))
(= l (list nil nil nil 5 6 7 8))
(test "And make sure that the empty values are empty!"
      (empty? ((apply f l) 2)))


(= b (lpm '(*a (id *b (4 6)) *c) 
          (list nil nil nil 5 6 7 8 nil nil)))
(test "Find the four to six things that are not nil!  Proper branching!"
      (and b (== '(5 6 7 8) (b 'b))))

(= b (lpm '((symbol? *a) (regex? b (1 2)) (int? *c) (true d 3))
          '(some-symbol 
             [a regex] [another one] 
             1 2 3 4 5
             () () ())))
(test "More complicated."
      (and b (== '(1 2 5 3) (b '(map length (list a b c d))))))

(TODO "Back references" "'or" "'any")

(= b (lpm '((sub a (b (int? c)))) '((1 2))))
(test "Matching a sub-pattern." b)
(test "Filling in the sub-pattern appropriately."
      (== '((1 2) 1 2) (map b '(a b c))))

(= b (lpm '((sub a ((int? i))) *b (sub c ((int? j)))) '((1) (2) (j) (3) (4))))
(test "Matching multiple sub-patterns." b)
(test "...*And* filling them in!"
      (== '((1) ((2) (j) (3)) (4) 1 4)
          (map b '(a b c i j))))

; Here's an idea, how about (= (pulled_thing remainder) (pull pattern list))?
'(= (two-things r) (pull '(a b) (list 1 2 3))) ; => ((1 2) (3))
'(= (three-chars remainder) (pull [...] "Hello")) ; => ("Hel" "lo")

(puts "(Black holes!)")
(= black-hole ...)
(= ... false)
(test "Assigning to the black hole doesn't actually change it."
      (== black-hole ...))

(= worked? (= (a *... d) '(1 2 3 4)))
(test "List assignment to the black hole." worked?)
(test "Did it work?" (== (list a d) '(1 4)))
