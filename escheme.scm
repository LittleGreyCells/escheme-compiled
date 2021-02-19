(define (accume-options args options)
  (if (null? args)
      options
      (let ((arg (car args)))
        (if (equal? (substring arg 0 1) "-")
            (accume-options (cdr args) (cons arg options))
            (accume-options (cdr args) options)))))

(let ((args (cdr (vector->list (getargs))))
      (interp #f)
      (usage 
       (lambda ()
	 (display "escheme-compiled [(-i | --interpreter) | (-h | --help)] [files...]" )
         (newline))))
  (let ((arg (car args)))
    (cond ((or (equal? arg "--interpreter") (equal? arg "-i"))
           (set! interp #t)
           (set! args (cdr args)))
          ((or (equal? arg "--help") (equal? arg "-h"))
           (usage)
           (exit))))
  (let ((options (accume-options args nil)))
    (if options
        (begin
          (display "extra options not expected ")
          (display options)
          (newline)
          (usage)
          (exit))))
  (if interp
      (load (system-path "boot/boot-interpreter.scm"))
      (load (system-path "boot/boot-compiler.scm")))
  (let ((try-load
         (lambda (file)
           (let ((result (load file)))
             (if (null? result)
                 (error "load failed for" file))))))
    (for-each try-load args))
  )

;; [EOF]
