;;
;; compiler functions
;;

(define (decode-fun fun)
  (let ((exp (%closure-code fun)))
    (if (code? exp)
	(disassemble exp)
	exp)))

;; [EOF]
