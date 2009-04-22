(= pkgname 'SDL)
(import 'auto-c)
(merge! binding
        (ffi-bind "SDL" "SDL/SDL.h"
                  (init (ffi-func 'int 'SDL_Init '(int)))
                  (init-timer (ffi-const 'int 'SDL_INIT_TIMER))
                  (init-audio (ffi-const 'int 'SDL_INIT_AUDIO))
                  (init-video (ffi-const 'int 'SDL_INIT_VIDEO))
                  (init-cdrom (ffi-const 'int 'SDL_INIT_CDROM))
                  (init-joystick (ffi-const 'int 'SDL_INIT_JOYSTICK))
                  (init-everything (ffi-const 'int 'SDL_INIT_EVERYTHING))
                  (init-noparachute (ffi-const 'int 'SDL_INIT_NOPARACHUTE))
                  (init-eventthread (ffi-const 'int 'SDL_INIT_EVENTTHREAD))

                  (quit (ffi-func 'void 'SDL_Quit ()))

                  (get-video-info (ffi-func 'pointer 'SDL_GetVideoInfo()))

                  (set-video-mode 
                    (ffi-func 'pointer 'SDL_SetVideoMode '(int int int int)))
                  (swsurface (ffi-const 'int 'SDL_SWSURFACE))
                  (hwsurface (ffi-const 'int 'SDL_HWSURFACE))
                  (asyncblit (ffi-const 'int 'SDL_ASYNCBLIT))
                  (anyformat (ffi-const 'int 'SDL_ANYFORMAT))
                  (hwpalette (ffi-const 'int 'SDL_HWPALETTE))
                  (doublebuf (ffi-const 'int 'SDL_DOUBLEBUF))
                  (fullscreen (ffi-const 'int 'SDL_FULLSCREEN))
                  (opengl (ffi-const 'int 'SDL_OPENGL))
                  (openglblit (ffi-const 'int 'SDL_OPENGLBLIT))
                  (resizable (ffi-const 'int 'SDL_RESIZABLE))
                  (noframe (ffi-const 'int 'SDL_NOFRAME))

                  ; Surface manipulation
                  (free-surface (ffi-func 'void 'SDL_FreeSurface '(pointer)))
                  (lock-surface (ffi-func 'int 'SDL_LockSurface '(pointer)))
                  (unlock-surface (ffi-func 'int 'SDL_UnlockSurface '(pointer)))
                  ; f#%@ing C macros
                  ;(blit-surface (ffi-func 'int 'SDL_BlitSurface
                  ;                        '(pointer pointer pointer pointer)))
                  (blit-surface (ffi-func 'int 'SDL_UpperBlit
                                          '(pointer pointer pointer pointer)))
                  
                  (flip (ffi-func 'int 'SDL_Flip '(pointer)))

                  ; WM functions
                  (wm-set-caption 
                    (ffi-func 'void 'SDL_WM_SetCaption '(string string)))

                  ; Event
                  (wait-event (ffi-func 'int 'SDL_WaitEvent '(pointer)))

                  ; Joysticks
                  (num-joysticks (ffi-func 'int 'SDL_NumJoysticks ()))
                  (joystick-open (ffi-func 'pointer 'SDL_JoystickOpen '(int)))
                  (joystick-name (ffi-func 'string 'SDL_JoystickName '(int)))
                  (joystick-num-axes 
                    (ffi-func 'int 'SDL_JoystickNumAxes '(pointer))) 
                  (joystick-num-buttons
                    (ffi-func 'int 'SDL_JoystickNumButtons '(pointer)))
))

(shadow 'Image)
(= Image (ffi-bind "SDL_image" "SDL/SDL_image"
                   (load (ffi-func 'pointer 'IMG_Load '(string)))
))
