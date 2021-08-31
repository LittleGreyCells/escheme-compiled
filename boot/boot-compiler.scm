(define *version* "(compiler)")
(set-prompt "bce> ")

;; redefine eval
(define %%eval eval)
(eval (compile '(define (eval exp . env)
		  (if (null? env)
		      (%%eval (compile exp))
		      (%%eval (compile exp (car env)) (car env))))))

;; compile load
(define (load file . noisily)
  (if (not (string? file))
      (error "filename is not a string")
      (let ((port (open-input-file file)))
        (if port
          (let ((sexpr (read port)))
            (while (not (eof-object? sexpr))
                   (if noisily
                       (begin
                         (display ">> ")
                         (print sexpr)))
	      (eval sexpr)
	      (set! sexpr (read port)))
            (close-port port)))
        #t)))

(load (system-path "boot/standard-functions.scm"))
(load (system-path "macros/qquote.scm"))
(load (system-path "macros/macros-compiler.scm"))
(load (system-path "boot/standard-macros.scm"))
(load (system-path "boot/catch-throw.scm"))
;; (load (system-path "boot/modules.scm"))
(load (system-path "boot/decode-fun.scm"))

;; compile the rep loop
(set! *rep-loop*
  (lambda ()
    (while #t
      (let ((sexpr (read *terminal*)))
        (add-history sexpr)
        (print (eval sexpr))))))


;; [EOF]
