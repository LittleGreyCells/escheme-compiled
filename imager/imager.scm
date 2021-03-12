;;
;; Code Imager
;;
;;   (dump-file <iport> <oport> . noisily)
;;   (load-file <port>)
;;
;; How to use:
;;
;;   [0] enter escheme in interpreter mode
;;
;;   [1] load the compiler and imager:
;;         ece> (load "./imager/imager.scm")
;;         ece> (load "./compiler/compiler.scm")
;;  
;;   [2] dump the file of objects: 
;;         ece> (compiler-dump)
;;
;;       All dumpables are code objects. The compiler will turn every 
;;       symbolic expression it finds in the file into a code object which
;;       it will dump.
;;
;;   [3] When the core interpreter is started, one can load the compiler
;;       image as follows:
;;         ece> (load "./imager/imager.scm")
;;         ece> (compiler-load)
;;

(define dumper-verbose #f)

(if #f (begin
	 ;; essential preparation
	 (load "imager/imager.scm")
	 (load "compiler/compiler.scm")

	 ;; dump
	 (compiler-dump)

	 ;; load
	 (compiler-load)
	 ))

(define (dump-file <iport> <oport> . noisily)
  (letrec ((tag0 (lambda (port)
		   (write 0 port)
		   (display " " port)))
	   (tag1 (lambda (port)
		   (write 1 port)
		   (display " " port))) 
	   (dump-sexprs 
	    (lambda (sexprs port)
	      (display "(" port)
	      (display '<sexpr> port)
	      (display " " port)
	      (write (vector-length sexprs) port)
	      (display " " port)
	      (let ((index 0))
		(while (< index (vector-length sexprs))
		       (let ((object (vector-ref sexprs index)))
			 (if (environment? object)  (error "environment cannot be dumped" object))
			 (if (port? object)         (error "port cannot be dumped" object))
			 (if (closure? object)      (error "closure cannot be dumped" object))
			 (if (procedure? object)    (error "procedure cannot be dumped" object))
			 (if (promise? object)      (error "promise cannot be dumped" object))
			 (if (continuation? object) (error "continuation cannot be dumped" object))
			 (if (code? object)
			     (begin
			      (tag1 port)
			      (dump-code object port))
			     (begin
			       (tag0 port)
			       (write object port)
			       (display " " port))))
		       (set! index (1+ index))
		       ))
	      (display ") " port)
	      ))
	   (dump-code 
	     (lambda (code port)
	       (if (code? code)
		   (begin
                     (display "(" port)
		     (display '<code> port)
		     (display " " port)
		     (display (%get-bcodes code) port)
		     (display " " port)
		     (dump-sexprs (%get-sexprs code) port)
		     (display ") " port) 
		     )
		 (error "not dumpable" code)
		 )))
	   )
    (let ((sexpr (read <iport>)))
      (while (not (eof-object? sexpr))
	     (if noisily (begin (display ">> ") (print sexpr)))
	     (dump-code (compile sexpr) <oport>)
	     (newline <oport>)
	     (set! sexpr (read <iport>)))
      )))


(define (load-file <iport>)
  (letrec ((vector->bvec 
	    (lambda (v)
	      (let ((vlen (vector-length v)))
		(let ((bv (make-byte-vector vlen))
		      (index 0))
		  (while (< index vlen)
			 (byte-vector-set! bv index (vector-ref v index))
			 (set! index (1+ index)))
		  bv))))
	   (load-sexprs 
	    (lambda (x)
	      ;; x = (<size> ...)
	      (let ((<size> (car x)))
		(if (not (integer? <size>))
		    (error "not a legal size for sexprs vector" <size>))
		(let ((sexprs (make-vector <size>))
		      (index 0))
		  (while (< index <size>)
		    (set! x (cdr x))
		    ;; x = (<tag> <item> <tag> <item> ...)
		    (if dumper-verbose (print (list 'sexpr index x)))
		    (let ((tag (car x)))
		      (set! x (cdr x))
		      (cond ((= tag 0) (vector-set! sexprs index (car x)))
			    ((= tag 1) 
			     (let ((item (car x)))
			       (if (eq? (car item) '<code> )
				   (vector-set! sexprs index (load-code (cdr item)))
				 (error "expected <code>; got" item))))
			    (else (error "unrecognized tage" tag))))
		    (set! index (1+ index)))
		  sexprs))))
	   (load-code
	    (lambda (x)
	      (if dumper-verbose (print (list 'load-code x)))
	      ;; x = (#(...) (<sexpr> ...))
	      (let ((v (car x)))
		(if (not (vector? v))
		    (error "not a [byte] vector" v)
		  (let ((x (cadr x)))
		    ;; x = (<sexpr> ...)
		    (if (not (and (pair? x) (eq? (car x) '<sexpr>)))
			(error "not sexprs vector" x))
		    (let ((sexprs (load-sexprs (cdr x))))
		      (%make-code (vector->bvec v) sexprs))
		    )))
	      ))
	   (try-load-code 
	    (lambda (port)
	      (let ((x (read port)))
		(if (and (pair? x) (eq? (car x) '<code>))
		    (load-code (cdr x))
		    **eof**
		    ))))
	   )
      (let ((code (try-load-code <iport>)))
	(while (not (eof-object? code))
	  (if dumper-verbose (print (list 'loaded-code code)))
	  (eval code)
	  (set! code (try-load-code <iport>)))
	)))


(define (image-dump fname-in fname-out)
   (let ((<in> (open-input-file fname-in))
	 (<out> (open-output-file fname-out)))
     (dump-file <in> <out> 'noisily)
     (close-port <in>)
     (close-port <out>)))

(define (image-load fn-in)
  (let ((<in> (open-input-file fn-in)))
    (load-file <in>)
    (close-port <in>)))

;;
;; create the compiler image dump and load helpers
;;

(define (compiler-dump) 
  (image-dump "compiler/compiler.scm" "compiler/compiler-image.scm"))

(define (compiler-load)
  (image-load "compiler/compiler-image.scm"))

