(define *version* "v2.0 (interpreter)")
(set-prompt "ece> ")

(load (system-path "boot/standard-functions.scm"))
(load (system-path "macros/qquote.scm"))
(load (system-path "macros/macros-interpreter.scm"))
(load (system-path "boot/standard-macros.scm"))
(load (system-path "boot/catch-throw.scm"))

;; [EOF]
