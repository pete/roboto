; A collection of code to make Roboto more useful for scripting.

(= pkgname 'Shell)

(def ls *a
     (split [\n] ($ (join " " (cons "ls" (map to-s a))))))

(def escape str
     (+ "'" (gsub (to-s str) ['] "'\\''") "'"))
