(define *version* "v2.0 (compiler)")
(set-prompt "bce> ")

;; load the compiler
(load       (system-path "imager/imager.scm"))
(image-load (system-path "compiler/compiler-image.scm"))

;; redefine eval
(define %%eval eval)
(eval (compile '(define (eval exp . env)
		  (if (null? env)
		      (%%eval (compile exp))
		      (%%eval (compile exp (car env)) (car env))))))

(define (load file . noisily)
  (if (not (string? file))
      (error "filename is not a string")
      (let ((port (open-input-file file)))
        (if port
          (let ((sexpr (read port)))
            (while (not (eof-object? sexpr))
              (if noisily (begin (display ">> ") (print sexpr)))
	      (eval sexpr)
	      (set! sexpr (read port)))
            (close-port port)))
        #t)))

(load (system-path "macros/macros-compiler.scm"))
(load (system-path "macros/qquote.scm"))

(load (system-path "boot/standard-functions.scm"))

;; [EOF]
