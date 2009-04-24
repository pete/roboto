; Testing regexes.  No language is complete without them.

(puts "(regexes...which use brackets in this language.)")
(test "[a] matches \"a\"" (match? [a] "a"))
(test "[a] matches \"sdfasdf\"" (match? [a] "sdfasdf"))
(test "[^a] matches \"asdf\"" (match? [^a] "asdf"))
(test "But it doesn't match \"sdfa\"" (! match? [^a] "sdfa"))
(test "More complex one" (match? [^a.*f\.j?\].] "asdf.]Rasdfjkl;"))
(test "Another complex one" (match? [^a.*f\.\[\]$] "asdf.[]"))
(test "Nesting [] inside a regex." (match? [a[Js]df] "asdf"))

(puts "Okay, now we'll check whether match() returns lists of matches.")
(test "Ruby equivalent:  /(\\d+)/.match?(\"asdf1234jkl\").to_a"
      (== '("1234" "1234") (match [(\d+)] "asdf1234jkl")))

(puts "i have added options how awesome")

(test "Case-insensitive match."
      (== '("XyZ") ([xYz]i "asdf XyZ akjlsd")))
(test "Multi-line match"
      (== "worked" (gsub "as\ndf" [as.df]m "worked")))
