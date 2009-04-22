; Roboto's CGI library, such as it is.
; Working on calling C code for now, but this will look nicer when hashes are
; implemented.  Note the regex syntax:  brackets.
; Also, I should probably point out that this library is powering a CGI
; script or two that I'm using.
(= pkgname 'CGI)

(= qsplit (curry split [[&;]]))

(def query ()
     (bind (e (C 'getenv "QUERY_STRING"))
           (if (! empty? e) (qsplit e)
             argv)))

(frdef parse ()
       ()               (parse (query))
       ((string? s))    (parse (qsplit s))
       ((list? query))  (map (op split [=] it) query)
       (*w/e) (+ "iono:" (inspect w/e))
       )

(= escape (\ a -> acc (gsub! a " " "+") 
               (gsub it [[^a-zA-Z0-9_.-]+] 
                     (op map (curry sprintf "%%%x") (to-bytes it)))))

(def env ()
     (map (op list (to-sym (downcase (to-s it))) (C 'getenv it))
          '("GATEWAY_INTERFACE" "HTTP_ACCEPT" "HTTP_ACCEPT_ENCODING"
            "HTTP_ACCEPT_LANGUAGE" "HTTP_COOKIE" "HTTP_HOST" "HTTP_USER_AGENT"
            "REMOTE_ADDR" "REQUEST_METHOD" "SCRIPT_NAME" "SERVER_NAME"
            "SERVER_PORT" "SERVER_PROTOCOL" "SERVER_SOFTWARE")))

