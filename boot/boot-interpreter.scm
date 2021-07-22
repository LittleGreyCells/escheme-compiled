(define *version* "(interpreter)")
(set-prompt "ece> ")

(load (system-path "boot/standard-functions.scm"))
(load (system-path "macros/qquote.scm"))
(load (system-path "macros/macros-interpreter.scm"))
(load (system-path "boot/standard-macros.scm"))
(load (system-path "boot/catch-throw.scm"))
(load (system-path "boot/modules.scm"))

;; [EOF]
