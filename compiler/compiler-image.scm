(<code> #(19 0 20 1 33) (<sexpr> 2 0 caddr 0 ec:get-statements ) ) 
(<code> #(14 19 0 26 20 1 33) (<sexpr> 2 0 the-environment 0 ec:the-global-env ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 19 0 15 19 1 27) (<sexpr> 2 0 ec:the-global-env 0 eq? ) ) 0 (exp) 0 ec:global-env? ) ) 
(<code> #(25 0 1 2 1 20 2 33) (<sexpr> 3 1 (<code> #(40 0 1 0 0 14 21 0 1 15 19 1 26 29 30 22 0 19 2 32 30 0 14 21 0 1 15 19 3 26 41 0 9 14 5 14 5 14 21 1 0 15 21 0 0 15 18 4 15 18 5 15 19 6 26 12 15 19 7 26 12 15 19 8 27) (<sexpr> 9 0 (env) 0 null? 0 ec:the-global-env 0 car 0 val 0 return 0 ec:compile 0 ec:get-statements 0 assemble ) ) 0 (exp env) 0 compile ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 19 0 26 29 30 32 0 14 21 0 0 15 21 0 1 15 21 0 2 15 21 0 3 15 19 1 27 14 21 0 0 15 19 2 26 29 30 64 0 14 21 0 0 15 21 0 1 15 21 0 2 15 21 0 3 15 19 3 27 14 21 0 0 15 19 4 26 29 30 153 2 40 0 1 5 0 14 21 0 0 15 19 6 26 41 0 9 14 21 0 0 15 18 7 15 19 8 26 29 30 127 0 14 21 1 0 15 21 1 1 15 21 1 2 15 21 1 3 15 19 9 27 14 21 0 0 15 18 10 15 19 8 26 29 30 162 0 14 21 1 0 15 21 1 1 15 21 1 2 15 21 1 3 15 19 11 27 14 21 0 0 15 18 12 15 19 8 26 29 30 197 0 14 21 1 0 15 21 1 1 15 21 1 2 15 21 1 3 15 19 13 27 14 21 0 0 15 18 14 15 19 8 26 29 30 232 0 14 21 1 0 15 21 1 1 15 21 1 2 15 21 1 3 15 19 15 27 14 21 0 0 15 18 16 15 19 8 26 29 30 18 1 14 5 14 21 1 0 15 19 17 26 12 15 21 1 1 15 21 1 2 15 21 1 3 15 19 18 27 14 21 0 0 15 18 19 15 19 8 26 29 30 60 1 14 5 14 21 1 0 15 19 17 26 12 15 21 1 1 15 21 1 2 15 21 1 3 15 19 20 27 14 21 0 0 15 18 21 15 19 8 26 29 30 102 1 14 5 14 21 1 0 15 19 17 26 12 15 21 1 1 15 21 1 2 15 21 1 3 15 19 22 27 14 21 0 0 15 18 23 15 19 8 26 29 30 137 1 14 21 1 0 15 21 1 1 15 21 1 2 15 21 1 3 15 19 24 27 14 21 0 0 15 18 25 15 19 8 26 29 30 172 1 14 21 1 0 15 21 1 1 15 21 1 2 15 21 1 3 15 19 26 27 14 21 0 0 15 18 27 15 19 8 26 29 30 207 1 14 21 1 0 15 21 1 1 15 21 1 2 15 21 1 3 15 19 28 27 14 21 0 0 15 18 29 15 19 8 26 29 30 242 1 14 21 1 0 15 21 1 1 15 21 1 2 15 21 1 3 15 19 30 27 14 21 0 0 15 18 31 15 19 8 26 29 30 21 2 14 21 1 0 15 21 1 1 15 21 1 2 15 21 1 3 15 19 32 27 14 21 0 0 15 18 33 15 19 8 26 29 30 56 2 14 21 1 0 15 21 1 1 15 21 1 2 15 21 1 3 15 19 32 27 14 21 0 0 15 18 34 15 19 8 26 29 30 91 2 14 21 1 0 15 21 1 1 15 21 1 2 15 21 1 3 15 19 35 27 14 21 0 0 15 18 36 15 19 8 26 29 30 133 2 14 5 14 21 1 0 15 19 37 26 12 15 21 1 1 15 21 1 2 15 21 1 3 15 19 38 27 14 21 1 0 15 21 1 1 15 21 1 2 15 21 1 3 15 19 39 27 14 18 40 15 21 0 0 15 19 41 27) (<sexpr> 42 0 symbol? 0 ec:compile-symbol 0 atom? 0 ec:compile-atom 0 pair? 0 (x) 0 car 0 quote 0 eq? 0 ec:compile-quote 0 if 0 ec:compile-if 0 cond 0 ec:compile-cond 0 while 0 ec:compile-while 0 lambda 0 ec:nested-defines 0 ec:compile-lambda 0 let 0 ec:compile-let 0 letrec 0 ec:compile-letrec 0 delay 0 ec:compile-delay 0 access 0 ec:compile-access 0 and 0 ec:compile-and 0 or 0 ec:compile-or 0 begin 0 ec:compile-seq 0 sequence 0 set! 0 ec:compile-set! 0 define 0 ec:normalize-define 0 ec:compile-define 0 ec:compile-application 0 "ec:compile -- unrecognized expression" 0 error ) ) 0 (exp env target linkage) 0 ec:compile ) ) 
(<code> #(25 0 1 2 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 18 0 15 21 0 0 15 5 14 18 1 15 21 0 1 15 19 2 26 12 15 19 2 26 12 15 19 2 27) (<sexpr> 3 0 assign 0 const 0 list ) ) 0 (target arg) 0 ec:make-assign ) ) 
(<code> #(25 0 1 2 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 18 0 15 21 0 0 15 21 0 1 15 19 1 26 12 15 19 1 27) (<sexpr> 2 0 gref 0 list ) ) 0 (target arg) 0 ec:make-gref ) ) 
(<code> #(25 0 1 3 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 18 0 15 21 0 0 15 21 0 1 15 21 0 2 15 19 1 26 12 15 19 1 27) (<sexpr> 2 0 fref 0 list ) ) 0 (target depth index) 0 ec:make-fref ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 18 0 15 5 14 18 1 15 21 0 0 15 19 2 26 12 15 19 2 26 12 15 19 2 27) (<sexpr> 3 0 goto 0 label 0 list ) ) 0 (arg) 0 ec:make-goto ) ) 
(<code> #(25 0 1 0 0 20 2 33) (<sexpr> 3 1 (<code> #(18 0 33) (<sexpr> 1 0 ((goto (reg cont))) ) ) 0 () 0 ec:make-goto-cont ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 18 0 15 5 14 18 1 15 21 0 0 15 19 2 26 12 15 19 2 26 12 15 19 2 27) (<sexpr> 3 0 branch 0 label 0 list ) ) 0 (arg) 0 ec:make-branch ) ) 
(<code> #(25 0 1 0 0 20 2 33) (<sexpr> 3 1 (<code> #(18 0 33) (<sexpr> 1 0 ((branch (reg cont))) ) ) 0 () 0 ec:make-branch-cont ) ) 
(<code> #(25 0 1 0 0 20 2 33) (<sexpr> 3 1 (<code> #(18 0 33) (<sexpr> 1 0 ((test-false)) ) ) 0 () 0 ec:make-test-false ) ) 
(<code> #(25 0 1 0 0 20 2 33) (<sexpr> 3 1 (<code> #(18 0 33) (<sexpr> 1 0 ((test-true)) ) ) 0 () 0 ec:make-test-true ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 21 0 0 15 18 0 15 19 1 26 12 15 19 1 27) (<sexpr> 2 0 (reg val) 0 list ) ) 0 (test) 0 ec:make-test ) ) 
(<code> #(25 0 1 5 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 18 0 15 21 0 0 15 21 0 1 15 21 0 2 15 21 0 3 15 21 0 4 15 19 1 26 12 15 19 1 27) (<sexpr> 2 0 make-closure 0 list ) ) 0 (target code vars numv rest) 0 ec:make-closure ) ) 
(<code> #(25 0 1 3 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 18 0 15 21 0 0 15 5 14 18 1 15 21 0 1 15 19 2 26 12 15 5 14 18 3 15 21 0 2 15 19 2 26 12 15 19 2 26 12 15 19 2 27) (<sexpr> 4 0 get-access 0 const 0 list 0 reg ) ) 0 (target sym env) 0 ec:make-get-access ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 18 0 15 21 0 0 15 19 1 26 12 15 19 1 27) (<sexpr> 2 0 gset 0 list ) ) 0 (sym) 0 ec:make-gset ) ) 
(<code> #(25 0 1 2 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 18 0 15 21 0 0 15 21 0 1 15 19 1 26 12 15 19 1 27) (<sexpr> 2 0 fset 0 list ) ) 0 (depth index) 0 ec:make-fset ) ) 
(<code> #(25 0 1 3 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 18 0 15 21 0 0 15 5 14 18 1 15 21 0 1 15 19 2 26 12 15 18 3 15 5 14 18 4 15 21 0 2 15 19 2 26 12 15 19 2 26 12 15 19 2 27) (<sexpr> 5 0 set-access 0 const 0 list 0 (reg val) 0 reg ) ) 0 (target sym env) 0 ec:make-set-access ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 18 0 15 21 0 0 15 19 1 26 12 15 19 1 27) (<sexpr> 2 0 save 0 list ) ) 0 (reg) 0 ec:make-save ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 18 0 15 21 0 0 15 19 1 26 12 15 19 1 27) (<sexpr> 2 0 restore 0 list ) ) 0 (reg) 0 ec:make-restore ) ) 
(<code> #(25 0 1 3 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 18 0 15 21 0 0 15 21 0 1 15 21 0 2 15 19 1 26 12 15 19 1 27) (<sexpr> 2 0 extend-env 0 list ) ) 0 (reg nvars vars) 0 ec:make-extend-env ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 18 0 15 21 0 0 15 19 1 26 12 15 19 1 27) (<sexpr> 2 0 eset 0 list ) ) 0 (index) 0 ec:make-eset ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 18 0 15 21 0 0 15 19 1 26 12 15 19 1 27) (<sexpr> 2 0 delay 0 list ) ) 0 (code) 0 ec:make-delay ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 3 15 5 14 18 0 15 5 14 21 0 2 15 19 1 26 12 15 5 14 21 0 2 15 21 0 0 15 19 2 26 12 15 19 3 26 12 15 19 4 27) (<sexpr> 5 0 () 0 list 0 ec:make-assign 0 ec:make-ins-sequence 0 ec:end-with-linkage ) ) 0 (exp env target linkage) 0 ec:compile-atom ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 3 15 5 14 18 0 15 5 14 21 0 2 15 19 1 26 12 15 5 14 21 0 2 15 5 14 21 0 0 15 19 2 26 12 15 19 3 26 12 15 19 4 26 12 15 19 5 27) (<sexpr> 6 0 () 0 list 0 cadr 0 ec:make-assign 0 ec:make-ins-sequence 0 ec:end-with-linkage ) ) 0 (exp env target linkage) 0 ec:compile-quote ) ) 
(<code> #(25 0 1 3 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 1 15 19 0 26 29 30 15 0 18 1 33 40 0 3 2 0 14 21 0 1 15 19 3 26 41 0 18 4 41 1 18 1 41 2 9 14 21 0 2 15 19 5 26 29 30 54 0 21 0 0 29 30 124 0 14 21 1 0 15 5 14 21 0 0 15 19 6 26 12 15 19 7 26 29 30 99 0 14 21 1 2 15 21 0 1 15 19 8 26 22 0 2 32 121 0 14 21 0 1 15 19 9 26 22 0 1 14 21 0 0 15 19 10 26 22 0 0 32 39 0 14 21 0 2 15 19 5 26 29 30 166 0 14 21 1 0 15 5 14 21 1 1 15 19 11 26 12 15 5 14 21 1 2 15 19 9 26 12 15 19 12 27 21 0 2 33) (<sexpr> 13 0 ec:global-env? 0 () 0 (bindings index code) 0 environment-bindings 0 0 0 not 0 caar 0 eq? 0 cons 0 1+ 0 cdr 0 environment-parent 0 ec:lookup-symbol ) ) 0 (sym env depth) 0 ec:lookup-symbol ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(40 0 1 0 0 14 21 0 0 15 21 0 1 15 18 1 15 19 2 26 41 0 9 14 21 0 0 15 19 3 26 29 30 79 0 14 21 1 3 15 5 14 18 4 15 5 14 21 1 2 15 19 5 26 12 15 5 14 21 1 2 15 21 1 0 15 19 6 26 12 15 19 7 26 12 15 19 8 27 40 0 2 9 0 14 21 0 0 15 19 10 26 41 0 14 21 0 0 15 19 11 26 41 1 9 14 21 2 3 15 5 14 18 4 15 5 14 21 2 2 15 19 5 26 12 15 5 14 21 2 2 15 21 0 0 15 21 0 1 15 19 12 26 12 15 19 7 26 12 15 19 8 27) (<sexpr> 13 0 (result) 0 0 0 ec:lookup-symbol 0 null? 0 () 0 list 0 ec:make-gref 0 ec:make-ins-sequence 0 ec:end-with-linkage 0 (depth index) 0 car 0 cdr 0 ec:make-fref ) ) 0 (exp env target linkage) 0 ec:compile-symbol ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 19 0 27) (<sexpr> 1 0 ec:new-label-number ) ) 0 (x) 0 ec:make-label2 ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(40 0 3 0 0 14 18 1 15 19 2 26 41 0 14 18 3 15 19 2 26 41 1 14 18 4 15 19 2 26 41 2 9 40 0 3 5 0 14 5 14 21 1 0 15 19 6 26 12 15 21 1 1 15 18 7 15 18 8 15 19 9 26 41 0 14 5 14 21 1 0 15 19 10 26 12 15 21 1 1 15 21 1 2 15 5 14 18 8 15 21 1 3 15 19 11 26 29 30 107 0 21 0 2 32 110 0 21 1 3 12 15 19 9 26 41 1 14 5 14 21 1 0 15 19 12 26 12 15 21 1 1 15 21 1 2 15 21 1 3 15 19 9 26 41 2 9 14 21 0 0 15 5 14 5 14 18 13 15 18 14 15 5 14 5 14 19 15 26 12 15 5 14 21 1 1 15 19 16 26 12 15 19 17 26 12 15 19 18 26 12 15 5 14 5 14 21 1 0 15 21 0 1 15 19 19 26 12 15 5 14 21 1 1 15 21 0 2 15 19 19 26 12 15 19 20 26 12 15 21 1 2 15 19 19 26 12 15 19 19 27) (<sexpr> 21 0 (true-label false-label end-label) 0 true-branch 0 ec:make-label2 0 false-branch 0 end-branch 0 (condition then-part else-part) 0 cadr 0 val 0 next 0 ec:compile 0 caddr 0 eq? 0 cadddr 0 (val) 0 () 0 ec:make-test-false 0 ec:make-branch 0 append 0 ec:make-ins-sequence 0 ec:append-ins-sequences 0 ec:parallel-ins-sequences ) ) 0 (exp env target linkage) 0 ec:compile-if ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(40 2 2 0 2 25 1 2 5 0 41 0 25 3 4 6 0 41 1 9 40 0 1 5 0 14 18 6 15 19 7 26 41 0 9 40 0 1 8 0 14 5 14 21 2 0 15 19 9 26 12 15 21 2 1 15 21 2 2 15 21 2 3 15 21 0 0 15 21 1 0 26 41 0 9 14 21 0 0 15 19 10 26 29 30 98 0 14 21 3 3 15 19 11 15 19 12 27 14 21 0 0 15 5 14 21 3 3 15 18 13 15 19 14 26 29 30 125 0 21 1 0 32 127 0 19 11 12 15 19 15 27) (<sexpr> 16 0 (compile-cond-clauses compile-cond-clause) 1 (<code> #(14 21 0 0 15 19 0 26 29 30 15 0 19 1 33 14 5 14 5 14 21 0 0 15 19 2 26 12 15 21 0 1 15 21 0 2 15 21 0 3 15 21 0 4 15 5 14 21 0 0 15 19 3 26 12 15 21 1 1 26 12 15 5 14 5 14 21 0 0 15 19 4 26 12 15 21 0 1 15 21 0 2 15 21 0 3 15 21 0 4 15 21 1 0 26 12 15 19 5 27) (<sexpr> 6 0 null? 0 nil 0 car 0 ec:last-exp? 0 cdr 0 ec:append-ins-sequences ) ) 0 (exp env target linkage end-label) 1 (<code> #(14 5 14 21 0 0 15 19 0 26 12 15 18 1 15 19 2 26 29 30 49 0 14 5 14 21 0 0 15 19 3 26 12 15 21 0 1 15 21 0 2 15 21 0 3 15 19 4 27 40 0 3 5 0 14 5 14 21 0 0 15 19 0 26 12 15 21 0 1 15 18 6 15 18 7 15 19 8 26 41 0 14 5 14 21 0 0 15 19 3 26 12 15 21 0 1 15 18 6 15 21 0 3 15 19 4 26 41 1 14 18 9 15 19 10 26 41 2 9 14 21 0 0 15 5 14 18 11 15 18 12 15 5 14 5 14 19 13 26 12 15 5 21 1 5 29 30 160 0 14 21 1 3 15 18 14 15 19 2 26 29 30 171 0 14 19 15 26 32 179 0 14 21 0 2 15 19 16 26 12 15 19 17 26 12 15 19 18 26 12 15 21 0 1 15 5 14 21 1 3 15 18 7 15 19 2 26 29 30 247 0 21 1 5 29 30 223 0 19 19 32 249 0 14 18 12 15 18 12 15 5 14 21 1 4 15 19 20 26 12 15 19 18 26 32 249 0 18 12 12 15 21 0 2 15 19 21 27) (<sexpr> 22 0 car 0 else 0 eq? 0 cdr 0 ec:compile-list 0 (<test> <body> false-label) 0 val 0 next 0 ec:compile 0 false-branch 0 ec:make-label2 0 (val) 0 () 0 ec:make-test-false 0 return 0 ec:make-branch-cont 0 ec:make-branch 0 append 0 ec:make-ins-sequence 0 nil 0 ec:make-goto 0 ec:append-ins-sequences ) ) 0 (exp env target linkage end-label last) 0 (end-label) 0 end-branch 0 ec:make-label2 0 (<clauses>) 0 cdr 0 null? 0 nil 0 ec:end-with-linkage 0 next 0 eq? 0 ec:append-ins-sequences ) ) 0 (exp env target linkage) 0 ec:compile-cond ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(40 0 2 0 0 14 18 1 15 19 2 26 41 0 14 18 3 15 19 2 26 41 1 9 40 0 2 4 0 14 5 14 21 1 0 15 19 5 26 12 15 21 1 1 15 18 6 15 18 7 15 19 8 26 41 0 14 5 14 21 1 0 15 19 9 26 12 15 21 1 1 15 21 1 2 15 18 7 15 19 10 26 41 1 9 14 21 1 0 15 21 0 0 15 5 14 18 11 15 18 12 15 5 14 5 14 19 13 26 12 15 5 14 21 2 3 15 18 14 15 19 15 26 29 30 134 0 14 19 16 26 32 142 0 14 21 1 1 15 19 17 26 12 15 19 18 26 12 15 19 19 26 12 15 21 0 1 15 5 14 18 12 15 18 12 15 5 14 21 1 0 15 19 20 26 12 15 19 19 26 12 15 21 1 1 15 19 21 27) (<sexpr> 22 0 (cond-label end-label) 0 cond-branch 0 ec:make-label2 0 end-branch 0 (<condition> <body>) 0 cadr 0 val 0 next 0 ec:compile 0 cddr 0 ec:compile-list 0 (val) 0 () 0 ec:make-test-false 0 return 0 eq? 0 ec:make-branch-cont 0 ec:make-branch 0 append 0 ec:make-ins-sequence 0 ec:make-goto 0 ec:append-ins-sequences ) ) 0 (exp env target linkage) 0 ec:compile-while ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 18 0 15 19 1 26 29 30 35 0 14 18 2 15 18 2 15 5 14 18 3 15 19 4 26 12 15 19 5 27 19 6 33) (<sexpr> 7 0 next 0 eq? 0 () 0 env 0 ec:make-save 0 ec:make-ins-sequence 0 nil ) ) 0 (linkage) 0 ec:save-lw-context ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 18 0 15 19 1 26 29 30 35 0 14 18 2 15 18 2 15 5 14 18 3 15 19 4 26 12 15 19 5 27 19 6 33) (<sexpr> 7 0 next 0 eq? 0 () 0 env 0 ec:make-restore 0 ec:make-ins-sequence 0 nil ) ) 0 (linkage) 0 ec:restore-lw-context ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(40 0 1 0 0 14 21 0 0 15 19 1 26 41 0 9 40 0 2 2 0 14 21 0 0 15 19 3 26 41 0 14 21 0 0 15 19 4 26 41 1 9 40 0 1 5 0 14 21 0 0 15 21 2 1 15 19 6 26 41 0 9 40 0 2 7 0 14 21 2 0 15 21 3 1 15 18 8 15 19 9 26 41 0 14 5 14 21 3 0 15 19 10 26 12 15 21 0 0 15 21 3 2 15 21 3 3 15 19 11 26 41 1 9 14 5 14 21 4 3 15 19 12 26 12 15 5 14 18 13 15 18 14 15 5 14 18 15 15 21 2 1 15 21 2 0 15 19 16 26 12 15 19 17 26 12 15 5 14 18 14 15 18 14 15 5 14 18 15 15 19 18 26 12 15 19 17 26 12 15 21 0 0 15 5 14 18 14 15 18 19 15 5 14 18 20 15 19 21 26 12 15 19 17 26 12 15 21 0 1 15 5 14 21 4 3 15 19 22 26 12 15 19 23 27) (<sexpr> 24 0 (<bindings>) 0 cadr 0 (<vars> <nvars>) 0 ec:get-let-vars 0 length 0 (<xenv>) 0 ec:extend-env 0 (<esets> <body>) 0 0 0 ec:compile-let-bindings 0 cddr 0 ec:compile-list 0 ec:save-lw-context 0 (env) 0 () 0 val 0 ec:make-extend-env 0 ec:make-ins-sequence 0 ec:make-save 0 (env) 0 env 0 ec:make-restore 0 ec:restore-lw-context 0 ec:append-ins-sequences ) ) 0 (exp env target linkage) 0 ec:compile-let ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(40 0 1 0 0 14 21 0 0 15 19 1 26 41 0 9 40 0 2 2 0 14 21 0 0 15 19 3 26 41 0 14 21 0 0 15 19 4 26 41 1 9 40 0 1 5 0 14 21 0 0 15 21 2 1 15 19 6 26 41 0 9 40 0 2 7 0 14 21 2 0 15 21 0 0 15 18 8 15 19 9 26 41 0 14 5 14 21 3 0 15 19 10 26 12 15 21 0 0 15 21 3 2 15 21 3 3 15 19 11 26 41 1 9 14 5 14 21 4 3 15 19 12 26 12 15 5 14 18 13 15 18 14 15 5 14 18 15 15 21 2 1 15 21 2 0 15 19 16 26 12 15 19 17 26 12 15 5 14 18 18 15 18 19 15 5 14 18 15 15 19 20 26 12 15 19 17 26 12 15 21 0 0 15 5 14 18 19 15 18 21 15 5 14 18 15 15 19 22 26 12 15 19 17 26 12 15 21 0 1 15 5 14 21 4 3 15 19 23 26 12 15 19 24 27) (<sexpr> 25 0 (<bindings>) 0 cadr 0 (<vars> <nvars>) 0 ec:get-let-vars 0 length 0 (<xenv>) 0 ec:extend-env 0 (<esets> <body>) 0 0 0 ec:compile-let-bindings 0 cddr 0 ec:compile-list 0 ec:save-lw-context 0 (env) 0 (env) 0 env 0 ec:make-extend-env 0 ec:make-ins-sequence 0 (env) 0 () 0 ec:make-save 0 (env) 0 ec:make-restore 0 ec:restore-lw-context 0 ec:append-ins-sequences ) ) 0 (exp env target linkage) 0 ec:compile-letrec ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 19 0 26 29 30 15 0 19 1 33 40 0 1 2 0 14 21 0 0 15 19 3 26 41 0 9 14 21 0 0 15 19 4 26 29 30 76 0 14 5 14 21 0 0 15 19 3 26 12 15 5 14 5 14 21 1 0 15 19 5 26 12 15 19 6 26 12 15 19 7 27 14 21 0 0 15 5 14 5 14 21 1 0 15 19 5 26 12 15 19 6 26 12 15 19 7 27) (<sexpr> 8 0 null? 0 nil 0 (x) 0 car 0 pair? 0 cdr 0 ec:get-let-vars 0 cons ) ) 0 (<bindings>) 0 ec:get-let-vars ) ) 
(<code> #(25 0 1 3 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 19 0 26 29 30 15 0 19 1 33 14 5 14 5 14 21 0 0 15 19 2 26 12 15 21 0 1 15 21 0 2 15 19 3 26 12 15 5 14 5 14 21 0 0 15 19 4 26 12 15 21 0 1 15 5 14 21 0 2 15 18 5 15 19 6 26 12 15 19 7 26 12 15 19 8 27) (<sexpr> 9 0 null? 0 nil 0 car 0 ec:compile-let-binding 0 cdr 0 1 0 + 0 ec:compile-let-bindings 0 ec:append-ins-sequences ) ) 0 (<bindings> env index) 0 ec:compile-let-bindings ) ) 
(<code> #(25 0 1 3 0 20 2 33) (<sexpr> 3 1 (<code> #(40 0 2 0 0 14 21 0 0 15 19 1 26 29 30 45 0 14 5 14 21 0 0 15 19 2 26 12 15 21 0 1 15 18 3 15 18 4 15 19 5 26 32 62 0 14 18 6 15 21 0 1 15 18 3 15 18 4 15 19 5 26 41 0 14 18 7 15 18 6 15 5 14 21 0 2 15 19 8 26 12 15 19 9 26 41 1 9 14 21 0 0 15 21 0 1 15 19 10 27) (<sexpr> 11 0 (value-code set-code) 0 pair? 0 cadr 0 val 0 next 0 ec:compile 0 () 0 (env) 0 ec:make-eset 0 ec:make-ins-sequence 0 ec:append-ins-sequences ) ) 0 (x env index) 0 ec:compile-let-binding ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(40 0 1 0 0 14 5 14 21 0 0 15 19 1 26 12 15 21 0 1 15 21 0 2 15 18 2 15 19 3 26 41 0 9 14 21 1 3 15 5 14 18 4 15 18 5 15 5 14 5 14 21 0 0 15 19 6 26 12 15 19 7 26 12 15 19 8 26 12 15 19 9 27) (<sexpr> 10 0 (code) 0 cadr 0 return 0 ec:compile 0 (val) 0 () 0 ec:get-statements 0 ec:make-delay 0 ec:make-ins-sequence 0 ec:end-with-linkage ) ) 0 (exp env target linkage) 0 ec:compile-delay ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(40 2 5 0 2 25 1 2 2 0 41 0 25 3 4 1 0 41 1 25 5 6 1 0 41 2 25 7 8 1 0 41 3 25 9 10 1 0 41 4 9 40 0 2 11 0 14 21 1 0 15 21 0 1 26 41 0 14 5 14 21 1 0 15 19 12 26 12 15 5 14 5 14 21 1 0 15 19 13 26 12 15 21 1 1 15 19 14 26 12 15 18 15 15 18 16 15 19 17 26 41 1 9 14 21 2 3 15 5 14 18 18 15 5 14 21 2 2 15 19 19 26 12 15 5 14 21 2 2 15 5 14 21 0 1 15 19 20 26 12 15 5 14 21 0 0 15 21 1 2 26 12 15 5 14 21 0 0 15 21 1 3 26 12 15 5 14 21 0 0 15 21 1 4 26 12 15 19 21 26 12 15 19 22 26 12 15 19 23 27) (<sexpr> 24 0 (get-arglist get-cattrs get-vars get-numv get-rest) 1 (<code> #(14 21 0 0 15 19 0 26 29 30 30 0 14 18 1 15 5 14 21 0 1 15 19 2 26 12 15 19 3 27 14 21 0 0 15 19 4 26 29 30 71 0 14 18 5 15 5 14 5 14 21 0 0 15 21 0 1 15 19 6 26 12 15 19 2 26 12 15 19 3 27 14 21 0 0 15 19 7 26 29 30 121 0 14 5 14 21 0 0 15 19 8 26 12 15 5 14 5 14 21 0 0 15 19 9 26 12 15 21 0 1 15 19 6 26 12 15 21 1 0 27 14 18 10 15 21 0 0 15 21 0 1 15 19 11 27) (<sexpr> 12 0 null? 0 norm 0 reverse 0 list 0 symbol? 0 rest 0 cons 0 pair? 0 cdr 0 car 0 "ec:compile-lambda -- malformed formal argument list" 0 error ) ) 0 (args alist) 1 (<code> #(14 5 14 21 0 0 15 19 0 26 12 15 19 1 15 21 1 0 27) (<sexpr> 2 0 cadr 0 nil ) ) 0 (exp) 1 (<code> #(14 21 0 0 15 19 0 27) (<sexpr> 1 0 cadr ) ) 0 (exp) 1 (<code> #(14 5 14 21 0 0 15 19 0 26 12 15 19 1 27) (<sexpr> 2 0 cadr 0 length ) ) 0 (exp) 1 (<code> #(14 5 14 21 0 0 15 19 0 26 12 15 18 1 15 19 2 27) (<sexpr> 3 0 car 0 rest 0 eq? ) ) 0 (exp) 0 (cattrs code) 0 cddr 0 cadr 0 ec:extend-env 0 val 0 return 0 ec:compile-list 0 () 0 list 0 ec:get-statements 0 ec:make-closure 0 ec:make-ins-sequence 0 ec:end-with-linkage ) ) 0 (exp env target linkage) 0 ec:compile-lambda ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(40 0 1 0 0 14 21 0 0 15 19 1 26 41 0 9 14 21 0 0 15 19 2 26 29 30 119 0 40 0 1 3 0 14 5 14 21 1 0 15 19 4 26 12 15 21 1 1 15 18 5 15 18 6 15 19 7 26 41 0 9 14 21 2 3 15 5 14 21 0 0 15 5 14 18 8 15 5 14 21 2 2 15 19 9 26 12 15 5 14 21 2 2 15 21 1 0 15 18 5 15 19 10 26 12 15 19 11 26 12 15 19 12 26 12 15 19 13 27 14 18 14 15 21 1 0 15 19 15 27) (<sexpr> 16 0 (sym) 0 cadr 0 symbol? 0 (env-code) 0 caddr 0 val 0 next 0 ec:compile 0 (val) 0 list 0 ec:make-get-access 0 ec:make-ins-sequence 0 ec:append-ins-sequences 0 ec:end-with-linkage 0 "ec:compile-access -- access expects a symbol" 0 error ) ) 0 (exp env target linkage) 0 ec:compile-access ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(40 0 1 0 0 14 21 0 0 15 19 1 26 41 0 9 14 21 0 0 15 19 2 26 29 30 222 0 40 0 2 3 0 14 5 14 21 1 0 15 19 4 26 12 15 21 1 1 15 18 5 15 18 6 15 19 7 26 41 0 14 21 0 0 15 21 1 1 15 18 8 15 19 9 26 41 1 9 14 21 0 1 15 19 10 26 29 30 141 0 14 21 2 3 15 5 14 21 0 0 15 5 14 18 11 15 5 14 21 2 2 15 19 12 26 12 15 5 14 21 1 0 15 19 13 26 12 15 19 14 26 12 15 19 15 26 12 15 19 16 27 40 0 2 17 0 14 21 0 1 15 19 18 26 41 0 14 21 0 1 15 19 19 26 41 1 9 14 21 3 3 15 5 14 21 1 0 15 5 14 18 20 15 5 14 21 3 2 15 19 12 26 12 15 5 14 21 0 0 15 21 0 1 15 19 21 26 12 15 19 14 26 12 15 19 15 26 12 15 19 16 27 14 21 0 0 15 19 22 26 29 30 252 0 14 5 14 21 0 0 15 19 18 26 12 15 18 23 15 19 24 26 29 30 178 1 40 0 3 25 0 14 21 0 0 15 19 1 26 41 0 14 5 14 21 0 0 15 19 4 26 12 15 21 1 1 15 18 5 15 18 6 15 19 7 26 41 1 14 5 14 21 1 0 15 19 4 26 12 15 21 1 1 15 18 5 15 18 6 15 19 7 26 41 2 9 14 21 2 3 15 5 14 21 0 1 15 5 14 5 14 5 14 18 26 15 18 27 15 18 28 15 19 14 26 12 15 21 0 2 15 5 14 18 27 15 18 29 15 18 30 15 19 14 26 12 15 19 15 26 12 15 5 14 18 31 15 5 14 21 2 2 15 19 12 26 12 15 5 14 21 2 2 15 21 0 0 15 18 32 15 19 33 26 12 15 19 14 26 12 15 19 15 26 12 15 19 15 26 12 15 19 16 27 14 18 34 15 21 1 0 15 19 35 27) (<sexpr> 36 0 (x) 0 cadr 0 symbol? 0 (value-code lookup-result) 0 caddr 0 val 0 next 0 ec:compile 0 0 0 ec:lookup-symbol 0 null? 0 (val) 0 list 0 ec:make-gset 0 ec:make-ins-sequence 0 ec:append-ins-sequences 0 ec:end-with-linkage 0 (depth index) 0 car 0 cdr 0 (val) 0 ec:make-fset 0 pair? 0 access 0 eq? 0 (sym env-code value-code) 0 (val) 0 () 0 ((save val)) 0 (exp) 0 ((restore exp)) 0 (val) 0 exp 0 ec:make-set-access 0 "ec:compile-set! -- illegal target for set!" 0 error ) ) 0 (exp env target linkage) 0 ec:compile-set! ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(21 0 1 29 30 21 0 14 18 0 15 21 0 0 15 19 1 26 32 23 0 18 2 40 0 1 3 0 25 4 5 1 0 41 0 9 40 0 2 6 0 14 5 14 21 1 0 15 19 7 26 12 15 21 0 0 26 41 0 14 5 14 21 1 0 15 19 8 26 12 15 21 1 1 15 18 9 15 18 10 15 19 11 26 41 1 9 14 21 2 3 15 5 14 21 0 1 15 5 14 18 12 15 5 14 21 2 2 15 19 13 26 12 15 5 14 21 0 0 15 19 14 26 12 15 19 15 26 12 15 19 16 26 12 15 19 17 27) (<sexpr> 18 0 "ec:compile-define -- internal defines not supported in this context" 0 error 0 () 0 (defn-sym) 1 (<code> #(14 21 0 0 15 19 0 26 29 30 16 0 21 0 0 33 14 18 1 15 21 0 0 15 19 2 27) (<sexpr> 3 0 symbol? 0 "ec:compile-define -- expected symbol in define form" 0 error ) ) 0 (exp) 0 (sym value-code) 0 cadr 0 caddr 0 val 0 next 0 ec:compile 0 (val) 0 list 0 ec:make-gset 0 ec:make-ins-sequence 0 ec:append-ins-sequences 0 ec:end-with-linkage ) ) 0 (exp env target linkage) 0 ec:compile-define ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(40 0 2 0 0 14 5 14 21 0 0 15 19 1 26 12 15 21 0 1 15 18 2 15 18 3 15 19 4 26 41 0 14 25 5 6 1 0 15 5 14 21 0 0 15 19 7 26 12 15 19 8 26 41 1 9 40 2 1 9 2 25 10 11 1 0 41 0 9 14 5 14 18 12 15 18 13 15 18 14 15 19 15 26 12 15 5 14 21 1 1 15 21 0 0 26 12 15 5 14 18 16 15 21 1 0 15 5 14 21 2 2 15 21 2 3 15 19 17 26 12 15 19 18 26 12 15 19 19 27) (<sexpr> 20 0 (func-code args-code) 0 car 0 val 0 next 0 ec:compile 1 (<code> #(14 21 0 0 15 21 1 1 15 18 0 15 18 1 15 19 2 27) (<sexpr> 3 0 val 0 next 0 ec:compile ) ) 0 (arg) 0 cdr 0 map 0 (pushargs) 1 (<code> #(14 21 0 0 15 19 0 26 29 30 15 0 18 1 33 14 5 14 18 2 15 5 14 21 0 0 15 19 3 26 12 15 5 14 18 4 15 18 5 15 18 6 15 19 7 26 12 15 19 8 26 12 15 5 14 5 14 21 0 0 15 19 9 26 12 15 21 1 0 26 12 15 19 10 27) (<sexpr> 11 0 null? 0 () 0 (argc) 0 car 0 (val argc) 0 (argc) 0 ((push-arg (reg val))) 0 ec:make-ins-sequence 0 ec:preserve 0 cdr 0 ec:append-ins-sequences ) ) 0 (x) 0 () 0 (argc) 0 ((zero-argc)) 0 ec:make-ins-sequence 0 (argc) 0 ec:compile-fun-call 0 ec:preserve 0 ec:append-ins-sequences ) ) 0 (exp env target linkage) 0 ec:compile-application ) ) 
(<code> #(25 0 1 2 0 20 2 33) (<sexpr> 3 1 (<code> #(14 18 0 15 18 1 15 5 14 21 0 1 15 18 2 15 19 3 26 29 30 28 0 18 4 32 66 0 14 21 0 1 15 18 5 15 19 3 26 29 30 48 0 18 6 32 66 0 14 18 7 15 5 14 21 0 1 15 19 8 26 12 15 19 9 26 12 15 19 10 27) (<sexpr> 11 0 (val argc) 0 (val env) 0 return 0 eq? 0 ((apply-cont)) 0 next 0 ((apply)) 0 ((apply)) 0 ec:make-goto 0 append 0 ec:make-ins-sequence ) ) 0 (target linkage) 0 ec:compile-fun-call ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 21 0 0 15 19 0 26 12 15 21 0 1 15 21 0 2 15 21 0 3 15 19 1 27) (<sexpr> 2 0 cdr 0 ec:compile-list ) ) 0 (exp env target linkage) 0 ec:compile-seq ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 19 0 26 28 30 20 0 14 21 0 0 15 19 1 26 29 30 51 0 14 5 14 21 0 0 15 19 2 26 12 15 21 0 1 15 21 0 2 15 21 0 3 15 19 3 27 14 5 14 5 14 21 0 0 15 19 2 26 12 15 21 0 1 15 21 0 2 15 18 4 15 19 3 26 12 15 5 14 5 14 21 0 0 15 19 5 26 12 15 21 0 1 15 21 0 2 15 21 0 3 15 19 6 26 12 15 19 7 27) (<sexpr> 8 0 null? 0 ec:last-exp? 0 car 0 ec:compile 0 next 0 cdr 0 ec:compile-list 0 ec:append-ins-sequences ) ) 0 (exp env target linkage) 0 ec:compile-list ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 21 0 1 15 18 0 15 21 0 2 15 21 0 3 15 19 1 27) (<sexpr> 2 0 test-false 0 ec:compile-and-or ) ) 0 (exp env target linkage) 0 ec:compile-and ) ) 
(<code> #(25 0 1 4 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 21 0 1 15 18 0 15 21 0 2 15 21 0 3 15 19 1 27) (<sexpr> 2 0 test-true 0 ec:compile-and-or ) ) 0 (exp env target linkage) 0 ec:compile-or ) ) 
(<code> #(25 0 1 2 0 20 2 33) (<sexpr> 3 1 (<code> #(14 18 0 15 18 0 15 5 14 21 0 0 15 18 1 15 19 2 26 29 30 30 0 14 19 3 26 32 38 0 14 21 0 1 15 19 4 26 12 15 19 5 27) (<sexpr> 6 0 () 0 return 0 eq? 0 ec:make-branch-cont 0 ec:make-branch 0 ec:make-ins-sequence ) ) 0 (linkage label) 0 ec:make-and-or-branch-code ) ) 
(<code> #(25 0 1 5 0 20 2 33) (<sexpr> 3 1 (<code> #(40 0 1 0 0 14 18 1 15 19 2 26 41 0 9 40 0 1 3 0 14 21 1 4 15 21 0 0 15 19 4 26 41 0 9 14 21 2 4 15 5 14 5 14 5 14 21 2 0 15 19 5 26 12 15 21 2 1 15 21 2 2 15 21 0 0 15 21 2 3 15 21 2 4 15 19 6 26 12 15 5 14 21 2 4 15 18 7 15 19 8 26 29 30 101 0 18 9 32 131 0 14 5 14 21 2 0 15 19 10 26 12 15 18 11 15 19 12 26 29 30 128 0 18 9 32 131 0 21 1 0 12 15 19 13 26 12 15 19 14 27) (<sexpr> 15 0 (end-label) 0 end 0 ec:make-label2 0 (branch-code) 0 ec:make-and-or-branch-code 0 cdr 0 ec:compile-and-or-seq 0 return 0 eq? 0 () 0 length 0 2 0 <= 0 ec:append-ins-sequences 0 ec:end-with-linkage ) ) 0 (exp env test target linkage) 0 ec:compile-and-or ) ) 
(<code> #(25 0 1 6 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 19 0 26 28 30 20 0 14 21 0 0 15 19 1 26 29 30 50 0 14 5 14 21 0 0 15 19 2 26 12 15 21 0 1 15 21 0 4 15 18 3 15 19 4 27 14 5 14 5 14 21 0 0 15 19 2 26 12 15 21 0 1 15 21 0 4 15 18 3 15 19 4 26 12 15 5 14 5 14 18 5 15 18 6 15 5 14 21 0 2 15 19 7 26 12 15 19 8 26 12 15 21 0 3 15 5 14 5 14 21 0 0 15 19 9 26 12 15 21 0 1 15 21 0 2 15 21 0 3 15 21 0 4 15 21 0 5 15 19 10 26 12 15 19 11 26 12 15 19 11 27) (<sexpr> 12 0 null? 0 ec:last-exp? 0 car 0 next 0 ec:compile 0 (val) 0 () 0 ec:make-test 0 ec:make-ins-sequence 0 cdr 0 ec:compile-and-or-seq 0 ec:append-ins-sequences ) ) 0 (exp env test branch-code target linkage) 0 ec:compile-and-or-seq ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 18 0 15 19 1 26 29 30 32 0 14 18 2 15 18 2 15 5 14 19 3 26 12 15 19 4 27 14 21 0 0 15 18 5 15 19 1 26 29 30 51 0 14 19 6 27 14 18 2 15 18 2 15 5 14 21 0 0 15 19 7 26 12 15 19 4 27) (<sexpr> 8 0 return 0 eq? 0 () 0 ec:make-goto-cont 0 ec:make-ins-sequence 0 next 0 ec:empty-ins-sequence 0 ec:make-goto ) ) 0 (linkage) 0 ec:compile-linkage ) ) 
(<code> #(25 0 1 2 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 1 15 5 14 21 0 0 15 19 0 26 12 15 19 1 27) (<sexpr> 2 0 ec:compile-linkage 0 ec:append-ins-sequences ) ) 0 (linkage ins-sequence) 0 ec:end-with-linkage ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 19 0 26 29 30 16 0 21 0 0 33 14 21 0 0 15 19 1 26 29 30 39 0 14 21 0 0 15 19 2 15 19 3 27 14 21 0 0 15 19 4 26 29 30 66 0 14 5 14 21 0 0 15 19 5 26 12 15 19 1 26 29 30 103 0 14 5 14 21 0 0 15 19 5 26 12 15 5 14 5 14 21 0 0 15 19 6 26 12 15 19 7 26 12 15 19 3 27 14 18 8 15 21 0 0 15 19 9 27) (<sexpr> 10 0 null? 0 symbol? 0 nil 0 cons 0 pair? 0 car 0 cdr 0 ec:normalize-arg-list 0 "ec:normalize-arg-list -- badly formed arg-list tail" 0 error ) ) 0 (x) 0 ec:normalize-arg-list ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 19 0 26 29 30 15 0 18 1 33 14 5 14 5 14 21 0 0 15 19 2 26 12 15 19 3 15 19 4 26 12 15 5 14 5 14 21 0 0 15 19 5 26 12 15 19 6 26 12 15 19 4 27) (<sexpr> 7 0 null? 0 () 0 car 0 nil 0 cons 0 cdr 0 ec:make-empty-bindings ) ) 0 (arg-list) 0 ec:make-empty-bindings ) ) 
(<code> #(25 0 1 2 0 20 2 33) (<sexpr> 3 1 (<code> #(40 0 1 0 0 14 21 0 0 15 19 1 26 41 0 9 14 5 14 21 0 0 15 19 2 26 12 15 21 1 1 15 19 3 27) (<sexpr> 4 0 (x) 0 ec:normalize-arg-list 0 ec:make-empty-bindings 0 %make-environment ) ) 0 (arg-list env) 0 ec:extend-env ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 21 0 0 15 19 0 26 12 15 19 1 27) (<sexpr> 2 0 cdr 0 null? ) ) 0 (exp) 0 ec:last-exp? ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 21 0 0 15 19 0 26 29 30 32 0 14 5 14 21 0 0 15 19 1 26 12 15 18 2 15 19 3 26 12 15 19 4 26 29 30 52 0 14 18 5 15 21 0 0 15 19 6 27 14 5 14 21 0 0 15 19 1 26 12 15 18 2 15 19 3 26 29 30 208 0 40 0 1 7 0 14 21 0 0 15 19 8 26 41 0 9 14 21 0 0 15 19 9 26 29 30 106 0 21 1 0 33 14 5 14 21 1 0 15 19 0 26 12 15 19 4 26 29 30 136 0 14 18 10 15 21 1 0 15 19 6 27 40 0 3 11 0 14 21 0 0 15 19 1 26 41 0 14 21 0 0 15 19 12 26 41 1 14 21 1 0 15 19 13 26 41 2 9 14 18 2 15 21 0 0 15 5 14 18 14 15 5 14 21 0 1 15 19 15 26 12 15 21 0 2 15 19 16 26 12 15 19 15 27 18 17 33) (<sexpr> 18 0 pair? 0 car 0 define 0 eq? 0 not 0 "ec:normalize-define -- not a define" 0 error 0 (x) 0 cadr 0 symbol? 0 "ec:normalize-define -- cannot normalze define" 0 (sym args body) 0 cdr 0 cddr 0 (lambda) 0 list 0 append 0 () ) ) 0 (d) 0 ec:normalize-define ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(40 0 4 0 0 14 21 0 0 15 19 1 26 41 0 14 21 0 0 15 19 2 26 41 1 25 3 4 1 0 41 2 25 5 6 1 0 41 3 9 40 0 1 7 0 14 21 0 1 15 21 0 2 26 41 0 9 14 5 14 21 0 0 15 19 1 26 12 15 19 8 26 29 30 80 0 21 2 0 33 40 0 4 9 0 14 19 10 15 5 14 21 0 0 15 19 1 26 12 15 19 11 26 41 0 14 21 1 3 15 5 14 21 0 0 15 19 1 26 12 15 19 11 26 41 1 14 5 14 21 0 0 15 19 12 26 12 15 19 13 26 41 2 14 21 2 0 15 19 10 26 41 3 9 14 21 2 0 15 21 0 3 15 5 14 18 14 15 5 14 21 0 0 15 19 15 26 12 15 21 0 1 15 21 0 2 15 19 16 26 12 15 19 15 27) (<sexpr> 17 0 (<kw> <body> accumulate-defines makeset) 0 car 0 cddr 1 (<code> #(40 0 2 0 0 18 1 41 0 18 1 41 1 9 21 1 0 29 30 127 0 2 40 0 1 2 0 14 21 1 0 15 19 3 26 41 0 9 14 21 0 0 15 19 4 26 29 30 68 0 14 5 14 21 0 0 15 19 3 26 12 15 18 5 15 19 6 26 29 30 97 0 14 5 14 21 0 0 15 19 7 26 12 15 21 1 0 15 19 8 26 22 1 0 32 112 0 14 21 0 0 15 21 1 1 15 19 8 26 22 1 1 14 21 2 0 15 19 9 26 22 2 0 9 32 14 0 14 21 0 0 15 21 0 1 15 19 8 27) (<sexpr> 10 0 (defines sexprs) 0 () 0 (x) 0 car 0 pair? 0 define 0 eq? 0 ec:normalize-define 0 cons 0 cdr ) ) 0 (body) 1 (<code> #(14 18 0 15 5 14 21 0 0 15 19 1 26 12 15 19 2 27) (<sexpr> 3 0 set! 0 cdr 0 cons ) ) 0 (d) 0 (pair) 0 null? 0 (<vars> <sets> <sexprs> <params>) 0 cadr 0 map 0 cdr 0 reverse 0 (let) 0 list 0 append ) ) 0 (<lambda>) 0 ec:nested-defines ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 19 0 26 28 30 20 0 14 21 0 0 15 19 1 26 29 30 27 0 18 2 33 14 21 0 0 15 19 3 27) (<sexpr> 4 0 symbol? 0 number? 0 () 0 car ) ) 0 (s) 0 ec:registers-needed ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 19 0 26 28 30 20 0 14 21 0 0 15 19 1 26 29 30 27 0 18 2 33 14 21 0 0 15 19 3 27) (<sexpr> 4 0 symbol? 0 number? 0 () 0 cadr ) ) 0 (s) 0 ec:registers-modified ) ) 
(<code> #(25 0 1 1 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 19 0 26 28 30 20 0 14 21 0 0 15 19 1 26 29 30 32 0 14 21 0 0 15 19 2 27 14 21 0 0 15 19 3 27) (<sexpr> 4 0 symbol? 0 number? 0 list 0 caddr ) ) 0 (s) 0 ec:statements ) ) 
(<code> #(25 0 1 2 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 1 15 5 14 21 0 0 15 19 0 26 12 15 19 1 27) (<sexpr> 2 0 ec:registers-needed 0 memq ) ) 0 (seq reg) 0 ec:needs-register? ) ) 
(<code> #(25 0 1 2 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 1 15 5 14 21 0 0 15 19 0 26 12 15 19 1 27) (<sexpr> 2 0 ec:registers-modified 0 memq ) ) 0 (seq reg) 0 ec:modifies-register? ) ) 
(<code> #(25 0 1 1 1 20 2 33) (<sexpr> 3 1 (<code> #(40 2 2 0 2 25 1 2 2 0 41 0 25 3 4 1 0 41 1 9 14 21 1 0 15 21 0 1 27) (<sexpr> 5 0 (append-2-sequences append-seq-list) 1 (<code> #(14 5 14 5 14 21 0 0 15 19 0 26 12 15 5 14 5 14 21 0 1 15 19 0 26 12 15 5 14 21 0 0 15 19 1 26 12 15 19 2 26 12 15 19 3 26 12 15 5 14 5 14 21 0 0 15 19 1 26 12 15 5 14 21 0 1 15 19 1 26 12 15 19 3 26 12 15 5 14 5 14 21 0 0 15 19 4 26 12 15 5 14 21 0 1 15 19 4 26 12 15 19 5 26 12 15 19 6 27) (<sexpr> 7 0 ec:registers-needed 0 ec:registers-modified 0 ec:difference 0 ec:union 0 ec:statements 0 append 0 ec:make-ins-sequence ) ) 0 (seq1 seq2) 1 (<code> #(14 21 0 0 15 19 0 26 29 30 16 0 14 19 1 27 14 5 14 21 0 0 15 19 2 26 12 15 5 14 5 14 21 0 0 15 19 3 26 12 15 21 1 1 26 12 15 21 1 0 27) (<sexpr> 4 0 null? 0 ec:empty-ins-sequence 0 car 0 cdr ) ) 0 (seqs) ) ) 0 (seqs) 0 ec:append-ins-sequences ) ) 
(<code> #(25 0 1 2 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 19 0 26 29 30 16 0 21 0 1 33 14 5 14 21 0 0 15 19 1 26 12 15 21 0 1 15 19 2 26 29 30 58 0 14 5 14 21 0 0 15 19 3 26 12 15 21 0 1 15 19 4 27 14 5 14 21 0 0 15 19 1 26 12 15 5 14 5 14 21 0 0 15 19 3 26 12 15 21 0 1 15 19 4 26 12 15 19 5 27) (<sexpr> 6 0 null? 0 car 0 memq 0 cdr 0 ec:union 0 cons ) ) 0 (s1 s2) 0 ec:union ) ) 
(<code> #(25 0 1 2 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 19 0 26 29 30 15 0 18 1 33 14 5 14 21 0 0 15 19 2 26 12 15 21 0 1 15 19 3 26 29 30 57 0 14 5 14 21 0 0 15 19 4 26 12 15 21 0 1 15 19 5 27 14 5 14 21 0 0 15 19 2 26 12 15 5 14 5 14 21 0 0 15 19 4 26 12 15 21 0 1 15 19 5 26 12 15 19 6 27) (<sexpr> 7 0 null? 0 () 0 car 0 memq 0 cdr 0 ec:difference 0 cons ) ) 0 (s1 s2) 0 ec:difference ) ) 
(<code> #(25 0 1 3 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 19 0 26 29 30 24 0 14 21 0 1 15 21 0 2 15 19 1 27 40 0 1 2 0 14 21 0 0 15 19 3 26 41 0 9 14 21 1 2 15 21 0 0 15 19 4 26 29 30 68 0 14 21 1 1 15 21 0 0 15 19 5 26 29 30 196 0 14 5 14 21 1 0 15 19 6 26 12 15 5 14 5 14 5 14 21 0 0 15 19 7 26 12 15 5 14 21 1 1 15 19 8 26 12 15 19 9 26 12 15 5 14 5 14 21 1 1 15 19 10 26 12 15 5 14 21 0 0 15 19 7 26 12 15 19 11 26 12 15 5 14 5 14 21 0 0 15 19 12 26 12 15 5 14 21 1 1 15 19 13 26 12 15 5 14 21 0 0 15 19 14 26 12 15 19 15 26 12 15 19 16 26 12 15 21 1 2 15 19 17 27 14 5 14 21 1 0 15 19 6 26 12 15 21 1 1 15 21 1 2 15 19 17 27) (<sexpr> 18 0 null? 0 ec:append-ins-sequences 0 (first-reg) 0 car 0 ec:needs-register? 0 ec:modifies-register? 0 cdr 0 list 0 ec:registers-needed 0 ec:union 0 ec:registers-modified 0 ec:difference 0 ec:make-save 0 ec:statements 0 ec:make-restore 0 append 0 ec:make-ins-sequence 0 ec:preserve ) ) 0 (regs seq1 seq2) 0 ec:preserve ) ) 
(<code> #(25 0 1 2 0 20 2 33) (<sexpr> 3 1 (<code> #(14 5 14 5 14 21 0 0 15 19 0 26 12 15 5 14 21 0 1 15 19 0 26 12 15 19 1 26 12 15 5 14 5 14 21 0 0 15 19 2 26 12 15 5 14 21 0 1 15 19 2 26 12 15 19 1 26 12 15 5 14 5 14 21 0 0 15 19 3 26 12 15 5 14 21 0 1 15 19 3 26 12 15 19 4 26 12 15 19 5 27) (<sexpr> 6 0 ec:registers-needed 0 ec:union 0 ec:registers-modified 0 ec:statements 0 append 0 ec:make-ins-sequence ) ) 0 (seq1 seq2) 0 ec:parallel-ins-sequences ) ) 
(<code> #(25 0 1 3 0 20 2 33) (<sexpr> 3 1 (<code> #(14 21 0 0 15 21 0 1 15 21 0 2 15 19 0 27) (<sexpr> 1 0 list ) ) 0 (needs modifies statements) 0 ec:make-ins-sequence ) ) 
(<code> #(25 0 1 0 0 20 2 33) (<sexpr> 3 1 (<code> #(14 18 0 15 18 0 15 18 0 15 19 1 27) (<sexpr> 2 0 () 0 ec:make-ins-sequence ) ) 0 () 0 ec:empty-ins-sequence ) ) 
(<code> #(18 0 20 1 33) (<sexpr> 2 0 0 0 ec:label-counter ) ) 
(<code> #(25 0 1 0 0 20 2 33) (<sexpr> 3 1 (<code> #(14 19 0 15 18 1 15 19 2 26 20 0 19 0 33) (<sexpr> 3 0 ec:label-counter 0 1 0 + ) ) 0 () 0 ec:new-label-number ) ) 
