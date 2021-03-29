;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;               E s c h e m e   C o m p i l e r
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;
;; Discussion
;;
;;   This implementation has strayed somewhat from that compiler introduced
;; in SICP. The major differences are registers and register tracking. The 
;; execution state (unev, env, pc) is no longer tracked individually, but 
;; saved/restored en benc as the function "partial-continuation".
;;
;;   The elaborate register tracking and save/restore mechanism (preserve) 
;; has limited but effective use for val, env and argc.
;;
;;   This "quick and dirty" first effort could benefit from code optimization
;; considerations. These are left to later updates.
;;

(define ec:compile-verbose #f)

(define (ec:trace . x)
  (if ec:compile-verbose
      (begin
       (display x)
       (newline)
       (flush-output *standard-output*))))

(define ec:get-statements caddr)

(define ec:the-global-env (the-environment))
(define (ec:global-env? exp) (eq? exp ec:the-global-env))

(define (compile exp . env)
  (let ((env (if (null? env) ec:the-global-env (car env))))
    (assemble (ec:get-statements (ec:compile exp env 'val 'return)))))

(define (ec:compile exp env target linkage)
  (cond ((symbol? exp) 	            (ec:compile-symbol exp env target linkage))
	((atom? exp)	            (ec:compile-atom exp env target linkage))
	((pair? exp) 
	 (let ((x (car exp)))
	   (cond ((eq? x 'quote)    (ec:compile-quote exp env target linkage))
		 ((eq? x 'if)       (ec:compile-if exp env target linkage))
		 ((eq? x 'cond)     (ec:compile-cond exp env target linkage))
		 ((eq? x 'while)    (ec:compile-while exp env target linkage))
		 
		 ((eq? x 'lambda)   (ec:compile-lambda (ec:nested-defines exp) env target linkage))
		 ((eq? x 'let)      (ec:compile-let (ec:nested-defines exp) env target linkage))
		 ((eq? x 'letrec)   (ec:compile-letrec (ec:nested-defines exp) env target linkage))
		 
		 ((eq? x 'delay)    (ec:compile-delay exp env target linkage))
		 ((eq? x 'access)   (ec:compile-access exp env target linkage))
		 ((eq? x 'and)      (ec:compile-and exp env target linkage))
		 ((eq? x 'or)       (ec:compile-or exp env target linkage))
		 ((eq? x 'begin)    (ec:compile-seq exp env target linkage))
		 ((eq? x 'sequence) (ec:compile-seq exp env target linkage))
		 ((eq? x 'set!)     (ec:compile-set! exp env target linkage))
		 ((eq? x 'define)   (ec:compile-define (ec:normalize-define exp)
						       env target linkage))
		 (else              (ec:compile-application exp env target linkage)))
	 ))
	(else
	 (error "ec:compile -- unrecognized expression" exp))
	))

;;
;; Instruction Constructors
;;
;;   If macro preprocessing were available at compiler loading time,
;; then the backquote patterns would be used. However, more tedious
;; consruction is required.
;;

;; `((assign ,target (const ,arg)))
(define (ec:make-assign target arg)
  (list (list 'assign target (list 'const arg))))

;; `((gref ,target ,arg))
(define (ec:make-gref target arg)
  (list (list 'gref target arg)))

;; `((fref target ,<depth> ,<index>))
(define (ec:make-fref target depth index)
  (list (list 'fref target depth index)))

;; `((goto (label ,arg)))
(define (ec:make-goto arg)
  (list (list 'goto (list 'label arg))))

;; '((goto (reg cont)))
(define (ec:make-goto-cont)
  '((goto (reg cont))))

;; `((branch (label ,arg)))
(define (ec:make-branch arg)
  (list (list 'branch (list 'label arg))))

;; '((branch (reg cont)))
(define (ec:make-branch-cont)
  '((branch (reg cont))))

;; `((test-false))
(define (ec:make-test-false)
  '((test-false)))

;; `((test-true))
(define (ec:make-test-true)
  '((test-true)))

;; `((,test (reg val)))
(define (ec:make-test test)
  (list (list test '(reg val))))

;;`((make-closure ,target ,code ,vars ,numv ,rest )
(define (ec:make-closure target code vars numv rest)
  (list (list 'make-closure target code vars numv rest )))

;; `((get-access ,target (const ,sym) (reg ,env))) )
(define (ec:make-get-access target sym env)
  (list (list 'get-access target (list 'const sym) (list 'reg env))))

;; `((gset ,sym))
(define (ec:make-gset sym)
  (list (list 'gset sym)))

;; `((fset ,depth ,index))
(define (ec:make-fset depth index)
  (list (list 'fset depth index)))

;; `((set-access ,target (const ,sym) (reg val) (reg ,env)))
(define (ec:make-set-access target sym env)
  (list (list 'set-access target (list 'const sym) '(reg val) (list 'reg env))))

;; `((save ,reg))
(define (ec:make-save reg)
  (list (list 'save reg)))

;; `((restore ,reg))
(define (ec:make-restore reg)
  (list (list 'restore reg)))

;; `((make-extend-env ,reg ,nvars ,vars))
(define (ec:make-extend-env reg nvars vars)
  (list (list 'extend-env reg nvars vars)))

;; `((eset ,index))
(define (ec:make-eset index)
  (list (list 'eset index)))

;; `((delay ,code))
(define (ec:make-delay code)
  (list (list 'delay code)))

;;
;; Register Usage
;;
;;   val    Evaluations go into val. usually not saved with the exception of
;;          set-access special handling.
;;
;;          With the removal of register fun, val becomes the single target register.
;;          there is also no need to preserve applicative order, so the function sexpr
;;          is evaluated last.
;;
;;   argc   Contains the count of the number of arguments accumulated on the argstack.
;;          this needs to be preserved across function and argument evaluations.
;;
;;   env    Hold the env of the currently executing function.
;;          needs to be preserved when function partial continuations
;;          are taken and elsewhere. See SAVE/RESTORE_BCE_REGISTERS.
;;
;;   unev   Holds the <code> object of the currently executing function.
;;          Needs to be preserved when function partial continuations
;;          are taken. See SAVE/RESTORE_BCE_REGISTERS.
;;
;;   pc     Holds the index into the <code> object of the currently executing function.
;;          Needs to be preserved when function partial continuations
;;          are taken. see SAVE/RESTORE_BCE_REGISTERS.
;;
;;   exp    Usually volatile and not needing any consideration, except in the
;;          case of set-access special handling where the evaluated access
;;          environment is restored into this register for set-access.
;; 

;;
;; Register Management
;;
;; (make-ins-sequence
;;    <needs>
;;    <modifies>
;;    <instructions> )
;;
;; (ec:preserve
;;    <regs>    ;; required by <seq2>
;;    <seq1>
;;    <seq2> )
;;

;;
;; ATOM
;;
(define (ec:compile-atom exp env target linkage)
  (ec:end-with-linkage
   linkage
   (ec:make-ins-sequence
    '()
    (list target)
    (ec:make-assign target exp)
    )))

;;
;; QUOTE
;;
(define (ec:compile-quote exp env target linkage)
  (ec:end-with-linkage 
   linkage
   (ec:make-ins-sequence 
    '() 
    (list target) 
    (ec:make-assign target (cadr exp))
    )))

;;
;; SYMBOL LOOKUP
;;
(define (ec:lookup-symbol sym env depth)
  (if (ec:global-env? env)
      '()
   (let ((bindings (environment-bindings env))
	 (index 0)
	 code)
     (while (and (not code) bindings)
	(if (eq? sym (caar bindings))
	    (begin
	      (set! code (cons depth index)))
	    (begin
	      (set! index (1+ index))
	      (set! bindings (cdr bindings))))
	)
     (if (not code)
	 (ec:lookup-symbol sym (environment-parent env) (1+ depth))
	 code)
     )))

;;
;; SYMBOL
;;
(define (ec:compile-symbol exp env target linkage)
  (let ((result (ec:lookup-symbol exp env 0)))
    (if (null? result)
	(ec:end-with-linkage
	 linkage
	 (ec:make-ins-sequence
	  '()
	  (list target)
	  (ec:make-gref target exp)
	  ))
      (let ((depth (car result))
	    (index (cdr result)))
	(ec:end-with-linkage
	 linkage
	 (ec:make-ins-sequence
	  '()
	  (list target)
	  (ec:make-fref target depth index)
	  ))))))

;;
;; IF
;;
(define (ec:make-label2 x) 
  (ec:new-label-number))

(define (ec:compile-if exp env target linkage)
  (let ((true-label (ec:make-label2 'true-branch))
	(false-label (ec:make-label2 'false-branch))
	(end-label (ec:make-label2 'end-branch)))
    (let ((condition (ec:compile (cadr exp) env 'val 'next))
	  (then-part (ec:compile (caddr exp) env target (if (eq? 'next linkage) end-label linkage)))
	  (else-part (ec:compile (cadddr exp) env target linkage)))
      ;; collapse candidate
      (ec:append-ins-sequences
       condition
       (ec:append-ins-sequences
	(ec:make-ins-sequence
	 '(val)
	 '()
	 (append (ec:make-test-false)
		 (ec:make-branch false-label))
	 )
	(ec:parallel-ins-sequences
	 (ec:append-ins-sequences true-label  then-part)
	 (ec:append-ins-sequences false-label else-part))
	end-label)))))

;;
;; COND
;;
(define (ec:compile-cond exp env target linkage)
  (let ((end-label (ec:make-label2 'end-branch)))
    (let ((<clauses> (ec:compile-cond-clauses (cdr exp) env target linkage end-label)))
      (if (null? <clauses>)
	  (ec:end-with-linkage
	   linkage
	   nil)
	  (ec:append-ins-sequences 
	   <clauses>
	   (if (eq? linkage 'next)
	       end-label
	       nil))
	  ))))

(define (ec:compile-cond-clauses exp env target linkage end-label)
  (if (null? exp)
      nil
      (ec:append-ins-sequences 
       (ec:compile-cond-clause (car exp) env target linkage end-label (ec:last-exp? exp))
       (ec:compile-cond-clauses (cdr exp) env target linkage end-label))
      ))

(define (ec:compile-cond-clause exp env target linkage end-label last)
  (if (eq? (car exp) 'else)
      (ec:compile-list (cdr exp) env target linkage)
      (let ((<test> (ec:compile (car exp) env 'val 'next))
	    (<body> (ec:compile-list (cdr exp) env 'val linkage))
	    (false-label (ec:make-label2 'false-branch)))
	(ec:append-ins-sequences
	 <test>
	 ;; test and branch code
	 ;;   if last and linkage is return, branch cont
	 ;;   if last and linkage is next, branch label
	 ;;   if not last and linkage is return, branch label
	 ;;   if not last and linkage is next, branch label
	 (ec:make-ins-sequence '(val) '() (append (ec:make-test-false)
						  (if (and last (eq? linkage 'return))
						      (ec:make-branch-cont)
						      (ec:make-branch false-label))))
	 <body>
	 ;; we are done
	 ;;   if last and linkage is next, nil (goto end is unnecessary)
	 ;;   if not last and linkage is next, goto end
	 (if (eq? linkage 'next)
	     (if last
		 nil
		 (ec:make-ins-sequence '() '() (ec:make-goto end-label))))
	 
	 false-label
	 ))))

;;
;; WHILE
;;
(define (ec:compile-while exp env target linkage)
  (let ((cond-label (ec:make-label2 'cond-branch))
	(end-label   (ec:make-label2 'end-branch  )))
    (let ((<condition> (ec:compile (cadr exp) env 'val 'next))
	  (<body> (ec:compile-list (cddr exp) env target 'next)))

      (ec:append-ins-sequences
       cond-label
       <condition>

       (ec:make-ins-sequence '(val) '() (append (ec:make-test-false)
						(if (eq? linkage 'return)
						    (ec:make-branch-cont)
						    (ec:make-branch end-label))))
       <body>

       (ec:make-ins-sequence '() '() (ec:make-goto cond-label))
       end-label
       )
      )))

;;
;; LET/LETREC
;;
;;   Strategy: 
;;     -if linkage is 'next then save env
;;       (otherwise the let/letrec will resume with goto-cont or branch-cont)
;;     -entend env with binding vars
;;       >let env takes effect after binding assignments
;;       >letrec env takes effect immediately
;;     -save env on stack
;;     -generate env assignment code for bindings (env on top of stack)
;;     -restore env from stack
;;     -generate code for body
;;     -if linkage is 'next then restore env
;;       (see comment above)
;;

(define (ec:save-lw-context linkage)
  (if (eq? linkage 'next) 
      (ec:make-ins-sequence '() '() (ec:make-save 'env)) 
      nil))

(define (ec:restore-lw-context linkage)
  (if (eq? linkage 'next) 
      (ec:make-ins-sequence '() '() (ec:make-restore 'env)) 
      nil))

;;
;; LET
;;
;;     (let <bindings> <body>)
;;
(define (ec:compile-let exp env target linkage)
  (let ((<bindings> (cadr exp)))
    (let ((<vars> (ec:get-let-vars <bindings>))
	  (<nvars> (length <bindings>)))
      (let ((<xenv> (ec:extend-env <vars> env)))
	(let ((<esets> (ec:compile-let-bindings <bindings> env 0))         ;; let uses env
	      (<body> (ec:compile-list (cddr exp) <xenv> target linkage)))
	  (ec:append-ins-sequences
	   (ec:save-lw-context linkage)
	   (ec:make-ins-sequence '(env) '() (ec:make-extend-env 'val <nvars> <vars>))
	   (ec:make-ins-sequence '() '() (ec:make-save 'val))
	   <esets>
	   (ec:make-ins-sequence '() '(env) (ec:make-restore 'env))
	   <body>
	   (ec:restore-lw-context linkage)
	  )))
      )))

;;
;; LETREC
;;
;;     (letrec <bindings> <body>)
;;

(define (ec:compile-letrec exp env target linkage)
  (let ((<bindings> (cadr exp)))
    (let ((<vars> (ec:get-let-vars <bindings>))
	  (<nvars> (length <bindings>)))
      (let ((<xenv> (ec:extend-env <vars> env)))
	(let ((<esets> (ec:compile-let-bindings <bindings> <xenv> 0))    ;; letrec uses xenv
	      (<body> (ec:compile-list (cddr exp) <xenv> target linkage)))
	  (ec:append-ins-sequences
	   (ec:save-lw-context linkage)
	   (ec:make-ins-sequence '(env) '(env) (ec:make-extend-env 'env <nvars> <vars>))
	   (ec:make-ins-sequence '(env) '() (ec:make-save 'env))
	   <esets>
	   (ec:make-ins-sequence '() '(env) (ec:make-restore 'env))
	   <body>
	   (ec:restore-lw-context linkage)
	  )))
      )))

(define (ec:get-let-vars <bindings>)
  (if (null? <bindings>)
      nil
      (let ((x (car <bindings>)))
	(if (pair? x)
	    (cons (car x) (ec:get-let-vars (cdr <bindings>)))
	    (cons x (ec:get-let-vars (cdr <bindings>)))))))

(define (ec:compile-let-bindings <bindings> env index)
  (if (null? <bindings>)
      nil
      (ec:append-ins-sequences 
       (ec:compile-let-binding (car <bindings>) env index)
       (ec:compile-let-bindings (cdr <bindings>) env (+ index 1)))))

(define (ec:compile-let-binding x env index)
  (let ((value-code (if (pair? x) 
			(ec:compile (cadr x) env 'val 'next)
			(ec:compile '() env 'val 'next)))
	(set-code (ec:make-ins-sequence '(env) '() (ec:make-eset index))))
    ;; collapse candidate
    (ec:append-ins-sequences 
     value-code 
     set-code)
    ))
		      
;;
;; DELAY
;;
;;    (delay <exp>)
;;
(define (ec:compile-delay exp env target linkage)
  (let ((code (ec:compile (cadr exp) env target 'return)))
    (ec:end-with-linkage
     linkage
     (ec:make-ins-sequence 
      '(val) 
      '() 
      (ec:make-delay (ec:get-statements code)))
     )))		 

;;
;; LAMBDA
;;
;;    (lambda <args> <body>)
;;
(define (ec:compile-lambda exp env target linkage)
  (letrec ((get-arglist
	    (lambda (args alist)
	      (if (null? args)
		  (list 'norm (reverse alist))
		  (if (symbol? args)
		      (list 'rest (reverse (cons args alist)))
		      (if (pair? args)
			  (get-arglist (cdr args) (cons (car args) alist))
			  (error "ec:compile-lambda -- malformed formal argument list" args alist))))))
	   (get-cattrs (lambda (exp) (get-arglist (cadr exp) nil)))
	   (get-vars (lambda (exp) (cadr exp)))
	   (get-numv (lambda (exp) (length (cadr exp))))
	   (get-rest (lambda (exp) (eq? (car exp) 'rest))))
    (let ((cattrs (get-cattrs exp))
	  (code (ec:compile-list (cddr exp) (ec:extend-env (cadr exp) env) 'val 'return)))
      (ec:end-with-linkage
       linkage
       (ec:make-ins-sequence
	'()
	(list target)
	(ec:make-closure target
			 (ec:get-statements code)
			 (get-vars cattrs)
			 (get-numv cattrs)
			 (get-rest cattrs))
	)))))

;;
;; ACCESS
;;
(define (ec:compile-access exp env target linkage)
  (let ((sym (cadr exp)))
    (if (symbol? sym)
	(let ((env-code (ec:compile (caddr exp) env 'val 'next)))
	  (ec:end-with-linkage
	   linkage
	   (ec:append-ins-sequences
	    env-code
	    (ec:make-ins-sequence
	     '(val)
	     (list target)
	     (ec:make-get-access target sym 'val)
	     ))))
	(error "ec:compile-access -- access expects a symbol" exp))))

;;
;; SET!
;;
(define (ec:compile-set-access-sym exp)
  (if (not (symbol? exp))
      (error "ec:compile-set-access-sym -- expected symbol in access form" exp)
      exp
      ))

(define (ec:compile-set-access-env exp env target linkage)
  (ec:compile exp env target linkage))

(define (ec:compile-set! exp env target linkage)
  (let ((x (cadr exp)))
    (cond ((symbol? x)
	   ;; (set! var <value>)
	   (let ((value-code (ec:compile (caddr exp) env 'val 'next))
		 (lookup-result (ec:lookup-symbol x env 0)))
	     (if (null? lookup-result)
		 (ec:end-with-linkage
		  linkage
		  ;; collapse candidate
		  (ec:append-ins-sequences 
		   value-code
		   (ec:make-ins-sequence
		    '(val)
		    (list target)
		    (ec:make-gset x)
		    )))
		 (let ((depth (car lookup-result))
		       (index (cdr lookup-result)))
		   (ec:end-with-linkage
		    linkage
		    ;; collapse candidate
		    (ec:append-ins-sequences 
		     value-code
		     (ec:make-ins-sequence
		      '(val)
		      (list target)
		      (ec:make-fset depth index)
		      ))
		    )))
	     ))
	  ((and (pair? x) (eq? (car x) 'access))
	   ;; (set! (access var env-expr)  <value>)
	   (let ((sym (cadr x))
		 (env-code (ec:compile (caddr x) env 'val 'next))
		 (value-code (ec:compile (caddr exp) env 'val 'next)))
	     (ec:end-with-linkage
	      linkage
	      (ec:append-ins-sequences
	       env-code
	       ;; collapse candidate
	       (ec:append-ins-sequences 
		(ec:append-ins-sequences
		 ;; save computed environment register
		 (ec:make-ins-sequence '(val) '() '((save val)))
		 value-code
		 ;; restore computed environment to exp
		 (ec:make-ins-sequence '() '(exp) '((restore exp))) )
		(ec:make-ins-sequence
		 '(val)
		 (list target)
		 (ec:make-set-access target sym 'exp)
		 ))
	       ))
	     ))
	  (else
	   (error "ec:compile-set! -- illegal target for set!" exp))) ))

;;
;; DEFINE
;;
(define (ec:defn-sym exp)
  (if (not (symbol? exp))
      (error "ec:defn-sym -- expected symbol in define form" exp)
      exp ))

(define (ec:compile-define exp env target linkage)
  (if env
      (error "ec:compile-define -- internal defines not supported" exp))
  (let ((sym (ec:defn-sym (cadr exp)))
	(value-code (ec:compile (caddr exp) env 'val 'next)))
    (ec:end-with-linkage
     linkage
     ;; collapse candidate
     (ec:append-ins-sequences 
      value-code
      (ec:make-ins-sequence 
       '(val)
       (list target) 
       (ec:make-gset sym)
       ))
     )))

;;
;; APPLICATION
;;
;;   -zero argc
;;   -for each arg do
;;      preserve argc
;;      compile arg
;;      push arg
;;   -compile func
;;   -funcall
;;

(define (ec:compile-application exp env target linkage)
  (let ((func-code (ec:compile (car exp) env 'val 'next))
	(args-code (map (lambda (arg) (ec:compile arg env 'val 'next)) (cdr exp))))
    (ec:append-ins-sequences
     (ec:make-ins-sequence '() '(argc) '((zero-argc)))
     (ec:pushargs args-code)
     (ec:preserve
      '(argc)
      func-code
      (ec:compile-fun-call target linkage)))
    ))


(define (ec:pushargs args-code)
  (if (null? args-code)
      '()
      (ec:append-ins-sequences
       (ec:preserve
	'(argc)
	(car args-code)
	(ec:make-ins-sequence '(val argc) '(argc) '((push-arg (reg val)))))
       (ec:pushargs (cdr args-code)))
      ))

;;
;; ec:compile-fun-call
;;
;; case 1: (target == val, linkage == next or label )
;;     (apply)
;;     [(goto ,label)]
;;   discussion: 
;;     apply already puts result in val
;;     [follow with label linkage]
;;
;; case 2: (target == val, linkage == return )
;;     (apply-cont)
;;   discussion: 
;;     apply-cont already puts result in val
;;     apply-cont does an implicit (goto (reg cont))
;;

(define (ec:compile-fun-call target linkage)
  (ec:make-ins-sequence
   '(val argc)                                                      ;; fun->val
   '(val env)
   (cond ((and (eq? target 'val) (not (eq? linkage 'return)))
	  ;;(ec:trace "target=val, linkage=next or label")
	  (if (eq? linkage 'next)
	      '((apply))
	      (append
	       '((apply))
	       (ec:make-goto linkage)))
	  )
	 ((and (eq? target 'val) (eq? linkage 'return))
	  ;;(ec:trace "target=val, linkage=return")
	  '((apply-cont))
	  )
	 (else
	  (error "ec:compile-fun-call -- unknown target and linkage combo"
		 (cons target linkage))))
   ))

;;
;; BEGIN/SEQUENCE
;;
(define (ec:compile-seq exp env target linkage)
  (ec:compile-list (cdr exp) env target linkage))

(define (ec:compile-list exp env target linkage)
  (if (or (null? exp) (ec:last-exp? exp)) 
      (ec:compile (car exp) env target linkage)
      ;; collapse candidate
      (ec:append-ins-sequences 
       (ec:compile (car exp) env target 'next)
       (ec:compile-list (cdr exp) env target linkage))))

;;
;; AND/OR
;;
(define (ec:compile-and exp env target linkage)
  (ec:compile-and-or exp env 'test-false target linkage))

(define (ec:compile-or exp env target linkage)
  (ec:compile-and-or exp env 'test-true target linkage))

(define (ec:make-and-or-branch-code linkage label)
  (ec:make-ins-sequence 
   '() 
   '() 
   (if (eq? linkage 'return)
       (ec:make-branch-cont)
       (ec:make-branch label))
   ))
 

(define (ec:compile-and-or exp env test target linkage)
  (let ((end-label (ec:make-label2 'end)))
    (let ((branch-code (ec:make-and-or-branch-code linkage end-label)))
      (ec:end-with-linkage
       linkage
       (ec:append-ins-sequences
	(ec:compile-and-or-seq (cdr exp) env test branch-code target linkage)
	(if (eq? linkage 'return) 
	    '() 
	    (if (<= (length exp) 2)
		'()
		end-label))))
      )))

(define (ec:compile-and-or-seq exp env test branch-code target linkage)
  (if (or (null? exp) (ec:last-exp? exp))
      (ec:compile (car exp) env target 'next)
    ;; collapse candidate
    (ec:append-ins-sequences 
      (ec:compile (car exp) env target 'next)
      (ec:append-ins-sequences
       (ec:make-ins-sequence 
	'(val) 
	'() 
	(ec:make-test test))
       branch-code
       (ec:compile-and-or-seq (cdr exp) env test branch-code target linkage)))
    ))

;;
;; linkage
;;

(define (ec:compile-linkage linkage)
  (cond ((eq? linkage 'return) (ec:make-ins-sequence '() '() (ec:make-goto-cont) ))
	((eq? linkage 'next)   (ec:empty-ins-sequence))
	(else                  (ec:make-ins-sequence '() '() (ec:make-goto linkage)))
	))

(define (ec:end-with-linkage linkage ins-sequence)
  ;; collapse candidate
  (ec:append-ins-sequences 
   ins-sequence
   (ec:compile-linkage linkage)) )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Syntax
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (ec:normalize-arg-list x)
  (cond ((null? x) x)
	((symbol? x) (cons x nil))
	((and (pair? x) (symbol? (car x)))
	 (cons (car x) (ec:normalize-arg-list (cdr x))))
	(else
	 (error "ec:normalize-arg-list -- badly formed arg-list tail" x))))

(define (ec:make-empty-bindings arg-list)
  (if (null? arg-list)
      '()
      (cons (cons (car arg-list) nil) (ec:make-empty-bindings (cdr arg-list)))))

(define (ec:extend-env arg-list env)
  (let ((x (ec:normalize-arg-list arg-list)))
    (%make-environment (ec:make-empty-bindings x) env)))

(define (ec:last-exp? exp) (null? (cdr exp)))

(define (ec:normalize-define d)
  (if (not (and (pair? d) (eq? (car d) 'define)))
      (error "ec:normalize-define -- not a define" d)
      (if (eq? (car d) 'define)
	  (let ((x (cadr d)))
	    (if (symbol? x)
		d
		(if (not (pair? d))
		    (error "ec:normalize-define -- cannot normalze define" d)
		    (let ((sym (car x))
			  (args (cdr x))
			  (body (cddr d)))
		      (list 'define sym (append '(lambda) (list args) body)))))))))

(if #t
(begin
;;
;; Nested Defines
;;
;;   (lambda (a b)
;;      (define (mul x y) (* x y))
;;      (define (add x y) (+ x y))
;;      (mul a (add a b)) )
;;    ==>
;;   (lambda (a b)
;;     (let (mul add)
;;       (set! mul (lambda (x y) (* x y)))
;;       (set! add (lambda (x y) (+ x y)))
;;       (mul a (add a b)) ))
;;
;; note 03/26/2021: nested defines added
;;

(define (ec:accumulate-defines body)
  (let ((defines '())
	(sexprs '()))
    (while body
       (let ((x (car body)))
	 (if (and (pair? x) (eq? (car x) 'define))
	     (set! defines (cons (ec:normalize-define x) defines))
	     (set! sexprs (cons x sexprs)))
	 (set! body (cdr body))))
    (cons defines sexprs)))

(define (ec:makeset d)
  (cons 'set! (cdr d)))

(define (ec:nested-defines <lambda>)
  (let ((<kw> (car <lambda>))
	(<body> (cddr <lambda>)))
    (let ((pair (ec:accumulate-defines <body>)))
      (if (null? (car pair))
	  <lambda>
	  (let ((<vars> (map cadr (car pair)))
		(<sets> (map ec:makeset (car pair)))
		(<sexprs> (reverse (cdr pair)))
		(<params> (cadr <lambda>)))
	    (list <kw>
		  <params>
		  (append '(let) (list <vars>) <sets> <sexprs>))
	    ))
      )))

))
      
;;
;; other compiler support functions
;;

(define (ec:registers-needed s)   (if (or (symbol? s) (number? s)) '() (car s)))
(define (ec:registers-modified s) (if (or (symbol? s) (number? s)) '() (cadr s)))
(define (ec:statements s)         (if (or (symbol? s) (number? s)) (list s) (caddr s)))

(define (ec:needs-register? seq reg) (memq reg (ec:registers-needed seq)))
(define (ec:modifies-register? seq reg) (memq reg (ec:registers-modified seq)))

(define (ec:append-ins-sequences . seqs)
  (letrec ((append-2-sequences 
	    (lambda (seq1 seq2)
	      (ec:make-ins-sequence
	       (ec:union (ec:registers-needed seq1)
			 (ec:difference (ec:registers-needed seq2)
					(ec:registers-modified seq1)) )
	       (ec:union (ec:registers-modified seq1)
			 (ec:registers-modified seq2))
	       (append (ec:statements seq1) (ec:statements seq2))
	       )))
	   (append-seq-list 
	    (lambda (seqs)
	      (if (null? seqs)
		  (ec:empty-ins-sequence)
		  (append-2-sequences (car seqs) (append-seq-list (cdr seqs)))))))
    (append-seq-list seqs)))

;; union: s1 + s2

(define (ec:union s1 s2)
  (cond ((null? s1) s2)
        ((memq (car s1) s2) (ec:union (cdr s1) s2))
        (else (cons (car s1) (ec:union (cdr s1) s2))) ))

;; difference: s1 - s2

(define (ec:difference s1 s2)
  (cond ((null? s1) '())
        ((memq (car s1) s2) (ec:difference (cdr s1) s2))
        (else (cons (car s1) (ec:difference (cdr s1) s2))) ))

(define (ec:preserve regs seq1 seq2)
  (if (null? regs)
      (ec:append-ins-sequences seq1 seq2)
    (let ((first-reg (car regs)) )
      (if (and (ec:needs-register? seq2 first-reg)
	       (ec:modifies-register? seq1 first-reg))
          (ec:preserve 
           (cdr regs)
           (ec:make-ins-sequence
            (ec:union (list first-reg) (ec:registers-needed seq1))
            (ec:difference (ec:registers-modified seq1) (list first-reg))
            (append 
	     (ec:make-save first-reg)
	     (ec:statements seq1)
	     (ec:make-restore first-reg)
	     ))
           seq2)
	  (ec:preserve (cdr regs) seq1 seq2) )) ))

(define (ec:parallel-ins-sequences seq1 seq2)
  (ec:make-ins-sequence
   (ec:union (ec:registers-needed seq1)
	     (ec:registers-needed seq2))
   (ec:union (ec:registers-modified seq1)
	     (ec:registers-modified seq2))
   (append (ec:statements seq1)
           (ec:statements seq2)) ))

(define (ec:make-ins-sequence needs modifies statements)
  (list needs modifies statements))

(define (ec:empty-ins-sequence)
  (ec:make-ins-sequence '() '() '()) )

(define ec:label-counter 0)

(define (ec:new-label-number)
  (set! ec:label-counter (+ ec:label-counter 1))
  ec:label-counter)

(define (ec:make-label name)
  (string->symbol (string-append (symbol->string name)
                                 (integer->string (ec:new-label-number))) ))

;; [end]


