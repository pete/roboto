#!/usr/bin/env roboto

(import 'sdl)

(def getjoy ()
     (bind ((n ((SDL 'num-joysticks)))
            (i 0)
            (j nil))
           (while (< i n)
                  (when (= j (SDL 'joystick-open i)) 
                    (printf "Found a %s, %d axes, %d buttons.\n"
                            (SDL 'joystick-name i)
                            (SDL 'joystick-num-axes j)
                            (SDL 'joystick-num-buttons j))
                    (break))
                  (++ i))
           j))


(SDL '(init (b| init-video init-joystick)))

(= screen (SDL '(set-video-mode 1024 768 0 (b| doublebuf swsurface))))
(SDL '(wm-set-caption "Roboto in living color" "Or even iconified."))
(= joystick (getjoy))

(= img (SDL 'Image 'load "/home/pete/pics/w/flagrant-error.jpg"))
(when (null-pointer? img) 
  (fatal! "Couldn't load image!"))

(SDL 'blit-surface img null-pointer screen null-pointer)
(SDL 'flip screen)
(SDL 'free-surface img)

(sleep 1)


