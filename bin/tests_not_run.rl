
(import 'shell)

(= all-tests (- (Shell 'ls 'test/*.lisp) '("test/all.lisp")))
(= ttr (cdar (parse (File 'read "test/all.lisp"))))
(puts "Tests that are not included in test/all.lisp:"
      (map (op prepend it "\t") (- all-tests ttr)))
