((-1+ <number>) -> <fixnum>)
((1+ <number>) -> <fixnum>)
((abs <number>) -> <fixnum>)
((access <symbol> <env>) -> <symbol-value>)
((add-history <sexpr>) -> #t)
((all-symbols) -> <list>)
((and <sequence>) -> (#t | <evaluated-exp-in-sequence>))
((append <list1> <list2> ... <listn>) -> <list>)
((apply <fn> <arglist>) -> <exp-fn-result>)
((assoc <exp> <alist>) -> ((<exp> . <value>) | nil))
((assq <exp> <alist>) -> ((<exp> . <value>) | nil))
((assv <exp> <alist>) -> ((<exp> . <value>) | nil))
((atom? <exp>) -> <boolean>)
((begin <sequence>) -> <evaluated-tail-in-sequence>)
((boolean? <exp>) -> <boolean>)
((bound? <exp>) -> <boolean>)
((byte-vector? <exp>) -> <boolean>)
((byte-vector {<exp>}*) -> <bvec>)
((byte-vector-length <byte-vector>) -> <fixnum>)
((byte-vector-ref <bvec> <index>) -> <value>)
((byte-vector-set! <bvec> <index> <value>) -> <value>)
((call/cc <fn>) -> <exp-fn-result>)
((car (<exp1> . <exp2>)) -> <exp1>)
((cdr (<exp1> . <exp2>)) -> <exp2>)
((ceiling <number>) -> <fixnum>)
((char-alphabetic? <char>) -> <boolean>)
((char<=? <char> <char>) -> <boolean>)
((char<? <char> <char>) -> <boolean>)
((char=? <char> <char>) -> <boolean>)
((char>=? <char> <char>) -> <boolean>)
((char>? <char> <char>) -> <boolean>)
((char-ci<=? <char> <char>) -> <boolean>)
((char-ci<? <char> <char>) -> <boolean>)
((char-ci=? <char> <char>) -> <boolean>)
((char-ci>=? <char> <char>) -> <boolean>)
((char-ci>? <char> <char>) -> <boolean>)
((char-downcase <char>) -> <char>)
((char? <exp>) -> <boolean>)
((char->integer <char>) -> <fixnum>)
((char-lower-case? <char>) -> <boolean>)
((char-numeric? <char>) -> <boolean>)
((char-upcase <char>) -> <char>)
((char-upper-case? <char>) -> <boolean>)
((char-whitespace? <char>) -> <boolean>)
((chdir <string>) -> <fixnum>)
((clear-history) -> #t)
((close-input-port <port>) -> #t)
((close-output-port <port>) -> #t)
((close-port <port>) -> #t)
((%closure-benv <closure>) -> <env>)
((%closure-code <closure>) -> <code>)
((%closure-code <closure>) -> <list>)
((closure? <exp>) -> <boolean>)
((%closure-numv <closure>) -> <fixnum>)
((%closure-rest <closure>) -> <boolean>)
((%closure-vars <closure>) -> <list>)
((code? <exp>) -> <boolean>)
((compile <exp> (<env>)) -> <code>)
((complex? <exp>) -> <boolean>)
((cond (<exp> <sequence>) ...) -> (#f | <evaluated-tail-in-sequence>))
((cons <car> <cdr>) -> <pair>)
((cxxr <pair>) -> <exp>)
((cxxxr <pair>) -> <exp>)
((cxxxxr <pair>) -> <exp>)
((dec <number>) -> <fixnum>)
((default-object? <exp>) -> <boolean>)
((define <var> <exp>) -> <var>)
((dict-items <dict>) -> <list>)
((dict-ref <dic> <key>) -> <sexpr>)
((dict-set! <dic> <key> <value>) -> <value>)
((display <sexpr> (<outport>)) -> #t)
((environment-bindings <env>) -> (<pair1> <pair2> ...))
((environment? <exp>) -> <boolean>)
((environment-parent <env>) -> <env>)
((eof-object? <exp>) -> <boolean>)
((eq? <exp1> <exp2>) -> <boolean>)
((equal? <exp1> <exp2>) -> <boolean>)
((eqv? <exp1> <exp2>) -> <boolean>)
((eval <exp> (<env>)) -> <exp-evaluated>)
((even? <exp>) -> <boolean>)
((exact? <exp>) -> <boolean>)
((exit) -> <never-returns>)
((find <string> <substring>) -> <fixnum-pos>)
((floor <number>) -> <fixnum>)
((flush-output (<outport>)) -> #t)
((force <promise>) -> <promise-evaluated>)
((foreach <fn> <list1> <list2> ...) -> nil)
((fs) --> <framestore-statistics>)
((gcd <fixnum>...) -> <fixnum>)
((gc) -> <vector-gc-statistics>)
((gensym (<sym>|<str>|<fix>)) -> <symbol>)
((getargs) -> #(<string0> <string1> ...))
((%get-bcodes <code>) -> <bvec>)
((getcwd) -> <string>)
((getenv <str-var>) -> <str-val>)
((get-file-position <port>) -> <fixnum>)
((%get-sexprs <code>) -> <sexpr-list>)
((get <sym> <prop>) -> <exp>)
((gettime) -> (<fixnum-seconds> . <fixnum-nanoseconds>))
((has-key <dict> <key>) -> <boolean>)
((history-add <sexpr>) -> #t)
((history-clear) -> #t)
((history-show) -> #t)
((history) -> #t)
((if <expr> <then-exp> <else-exp>) -> <evaluated-tail-in-exp>)
((inc <number>) -> <fixnum>)
((inexact? <exp>) -> <boolean>)
((input-port? <exp>) -> <boolean>)
((input-string-port? <exp>) -> <boolean>)
((integer->char <integer>) -> <char>)
((integer? <exp>) -> <boolean>)
((integer->string <fixnum>) -> <string>)
((lambda <fargs> <sequence>) -> <closure>)
((last-pair <list>) -> (<pair> | nil))
((length <list>) -> <fixnum>)
((let <bindings> <sequence>) -> <evaluated-tail-in-sequence>)
((let* <bindings> <sequence>) -> <evaluated-tail-in-sequence>)
((letrec <bindings> <sequence>) -> <evaluated-tail-in-sequence>)
((list? <exp>) -> <boolean>)
((list {<exp>}*) -> <list>)
((list* {<exp>}*) -> <list>)
((list->string <list-of-chars>) -> <string>)
((list-tail <list> <n>) -> (<list> | nil))
((list->vector <list>) -> <vector>)
((logand <fixnum>...) -> <fixnum>)
((logior <fixnum>...) -> <fixnum>)
((logxor <fixnum>...) -> <fixnum>)
((make-byte-vector <size>) -> <bvec>)
((%make-code <bvec> <vec>) -> <code>)
((make-dict) -> <dict>)
((%make-environment <pairs> <baseenv>) -> <env>)
((make-module) -> <module>)
((make-vector <size>) -> <vector>)
((map <fn> <list1> <list2> ...) -> <list-of-fn-results>)
((max <number>...) -> <number>)
((member <exp> <list>) -> (<exp> | nil))
((memq <exp> <list>) -> (<exp> | nil))
((memv <exp> <list>) -> (<exp> | nil))
((min <number>...) -> <number>)
((mm) -> <statisics>)
((module-dict <module>) -> <dict>)
((negative? <exp>) -> <boolean>)
((newline (<outport>)) -> #t)
((not <exp>) -> <boolean>)
((null? <exp>) -> <boolean>)
((number? <exp>) -> <boolean>)
((* <number>...) -> <number>)
((+ <number>...) -> <number>)
((- <number>...) -> <number>)
((/ <number>...) -> <number>)
((< <number>...) -> <number>)
((<= <number>...) -> <number>)
((= <number>...) -> <number>)
((> <number>...) -> <number>)
((>= <number>...) -> <number>)
((%object-address <object>) -> <fixnum>)
((odd? <exp>) -> <boolean>)
((open-append-file <str>) -> <port>)
((open-input-file <str>) -> <port>)
((open-input-string <str>) -> <stringport>)
((open-output-file <str>) -> <port>)
((open-output-string) -> <stringport>)
((open-update-file <str>) -> <port>)
((or <sequence>) -> (#f | <non-false-evaluated-exp-in-sequence>))
((output-port? <exp>) -> <boolean>)
((output-string-port? <exp>) -> <boolean>)
((pair? <exp>) -> <boolean>)
((port? <exp>) -> <boolean>)
((positive? <exp>) -> <boolean>)
((print <sexpr> (<outport>)) -> #t)
((procedure-environment <closure>) -> <env>)
((procedure? <exp>) -> <boolean>)
((promise? <exp>) -> <boolean>)
((put <sym> <prop> <value>) -> <prop>)
((quotient <fixnum>...) -> <fixnum>)
((random <fixnum>) -> <fixnum>)
((rational? <exp>) -> <boolean>)
((read-char (<inport>)) -> <char>)
((read (<inport>)) -> <exp>)
((real? <exp>) -> <boolean>)
((remainder <fixnum>...) -> <fixnum>)
((remprop <sym> <prop>) -> <null>)
((reverse <list>) -> <list>)
((round <number>) -> <fixnum>)
((sequence <sequence>) -> <evaluated-tail-in-sequence>)
((set! (access <var> <env>) <exp>) -> <exp-evaluated>)
((set-car! <pair> <newcar>) -> <pair>)
((set-cdr! <pair> <newcdr>) -> <pair>)
((setenv <str-var> <str-val>) -> <fixnum>)
((set-file-position <port> <pos>) -> #t)
((set-prompt <string>) -> #t)
((set-symbol-plist! <sym-expr> <plist>) -> <plist>)
((set-symbol-value! <sym-expr> <value>) -> <value>)
((set! <var> <exp>) -> <exp-evaluated>)
((shift-left <fixnum> <fixnum>) -> <fixnum>)
((shift-right-arithmetic <fixnum> <fixnum>) -> <fixnum>)
((shift-right <fixnum> <fixnum>) -> <fixnum>)
((string-append <str1> <str2> ... <sn>) -> <string>)
((string-ci<=? <str> <str>) -> <boolean>)
((string-ci<? <str> <str>) -> <boolean>)
((string-ci=? <str> <str>) -> <boolean>)
((string-ci>=? <str> <str>) -> <boolean>)
((string-ci>? <str> <str>) -> <boolean>)
((string-copy! <dest> <dest-start> <src> (<src-start> <src-end>)) -> <dest>)
((string-downcase! <str>) -> <string>)
((string-dup <str>) -> <str>)
((string? <exp>) -> <boolean>)
((string-fill! <str> <ch>) -> <string>)
((string-find <str1> <str2> [<start> [<end>]]) -> <fixnum-or-null>)
((string->integer <string>) -> <fixnum>)
((string-length <str>) -> <fixnum>)
((string->list <string>) -> <list-of-chars>)
((string-make <length> [<char>]) -> <string>)
((string-null? <str>) -> <boolean>)
((string-pad-left <str> <k> [<char>]) -> <string>)
((string-pad-right <str> <k> [<char>]) -> <string>)
((string-port? <exp>) -> <boolean>)
((string-ref <str> <index>) -> <char>)
((string-set! <str> <index> <ch>) -> <string>)
((string<=? <str> <str>) -> <boolean>)
((string<? <str> <str>) -> <boolean>)
((string=? <str> <str>) -> <boolean>)
((string>=? <str> <str>) -> <boolean>)
((string>? <str> <str>) -> <boolean>)
((string->symbol <str>) -> <symbol>)
((string-trim-left <str1> [<str2>]) -> <string>)
((string-trim-right <str1> [<str2>]) -> <string>)
((string-trim <str1> [<str2>]) -> <string>)
((string-upcase! <str>) -> <string>)
((substring <str> <start> <end>) -> <string>)
((symbol? <exp>) -> <boolean>)
((symbol-plist <sym-expr>) -> <plist>)
((symbol->string <sym>) -> <str>)
((symbol-value <sym-expr>) -> <value>)
((system <string>) -> <fixnum-return-code>)
((the-environment) -> <env>)
((transcript-off) -> #t)
((transcript-on <str>) -> #t)
((truncate <number>) -> <fixnum>)
((unsetenv <str-var>) -> <fixnum>)
((vector-copy! <dest> <dest-start> <src> (<src-start> <src-end>)) -> <dest>)
((vector? <exp>) -> <boolean>)
((vector {<exp>}*) -> <vector>)
((vector-fill! <vector> <value>) -> <vector>)
((vector-length <vector>) -> <fixnum>)
((vector->list <vector>) -> <list>)
((vector-ref <vector> <index>) -> <value>)
((vector-set! <vector> <index> <value>) -> <value>)
((while <cond> <sequence>) -> #f)
((write-char <sexpr> (<outport>)) -> #t)
((write <sexpr> (<outport>)) -> #t)
((zero? <exp>) -> <boolean>)
