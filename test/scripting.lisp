(puts "(Scripting.  Fairly important for little programs.)")
; Pipes
(test "pipe-str pipes a string into a command."
      (== "Hebbo\n" (pipe-str "Hello\n" "sed s/l/b/g")))
(= user ($ "id -nu"))
(test "Grepping /etc/passwd for my username"
      (== user (pipe "cat /etc/passwd" "grep #(($ "id -nu"))" "sed s/:.*//")))

; $def:  A shell definition function.
($def cat)
(= /etc/passwd (File 'read "/etc/passwd"))
(test "Just a simple $def test using cat."
      (== /etc/passwd (cat "/etc/passwd")))
