; String manipulation!  I am already kicking Common Lisp's ass with my fresh
; rhymes.

(test "Length of \"Hello\" is five" (== 5 (length "Hello")))
(test "gsubbin'" (== "jsdf" (gsub "asdf" [^a] "j")))
(test "gsub with a lambda" (== "jsdf" (gsub "asdf" [^a] (lambda s "j"))))
(test "join with emtpy string" (== "asdf" (join "" '("a" "s" "d" "f"))))
(test "join with a comma" (== "a,s,d,f" (join "," '("a" "s" "d" "f"))))
; I added the "map to-s" here, mainly because I am not sure that join is a
; strings-only operation.  It's implemented with '+'.  I am not sure that 
; join shouldn't be a strings-only operation, either.  
(test "join with non-string parts" 
      (== "as,df,5" (join "," (map to-s '("as" df 5)))))

(test "Interpolation with multiple expressions."
      (== "as" "#("a" "s")"))

(test "Handling UTF-8 correctly."
      (== "ら" (car "らりるれろ")))
(test "Handling ca/dr correctly."
      (== (list "ら" "りるれろ") (ca/dr "らりるれろ")))
