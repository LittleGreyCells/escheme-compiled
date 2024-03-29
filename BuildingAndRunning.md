Building and Running
====================

## Building

In the root directory type 'make' to build the executable:
```
   $ make
```

## Running
```
usage: escheme-compiled [(-i | --interpreter) | (-h | --help)] [files...]
```

### I. The Compiler

To run the compiler based REP loop, simply invoke escheme and the linenoise prompt is displayed:
```
   $ ./escheme-compiled
   escheme (compiler)
   
   bce>
```

It's escheme-compiled read/compile/eval/print loop indicated by the prompt "bce>", which
shows that the RCEP loop drives interaction.

To exit escheme, type ^D, ^C or exit function at the prompt:
```
   bce> (exit)
   $
```

### II. The Interpreter

To run the interpreter, invoke escheme  with -i/--intepreter. 
A banner is printed and the linenoise prompt is displayed:
```
   $ ./escheme-compiled -i
   escheme (interpreter)
   
   ece>
```

The prompt "ece>" shows that the interpreter's explicit control evaluator drives
interaction.


### III. Compiler Usage

Two suggested uses for the compiler:

   * Boot into the interpreter and compile individual objects; or,
   * Boot into the compiler capable system


#### 1. Compiling Individual Objects

This requires booting into the interpreter. To boot into the interpreter
from the build directory invoke escheme with -i/--interpreter option:
```
   $ ./escheme-compiled -i
   escheme (interpreter)
   
   # load the compiler
   ece> (load "./compiler/compiler.scm")

   # compile a function definition
   ece>(set! x '(define (double n) (* n 2)))
   ece>(set! x (compile x))  ;; creates a code object to define double
   ece>(eval x)              ;; this evaluates the code object which defines "double"
   ece>(double 10)           ;; use "double"
   20
```

#### 2. Booting into the Compiler Capable System

To boot into the compiler capable system simply invoke escheme:
```
   $ ./escheme-compiled
   escheme (compiler)
   
   bce>
```

Let's define a compiled version of double:
```
   bce> (define (double n) (* n 2))
   bce> (double 10)
   20
```

The code produced:
```
  bce> (decode-fun double)
  0:begin
  0:sexprs #(2 *)
  0:0000: 0e  .  .  .  . zero-argc
  0:0001: 15 00 00  .  . fref [val,]0,0
  0:0004: 0f  .  .  .  . push-arg
  0:0005: 12 00  .  .  . assign-obj [val,]2
  0:0007: 0f  .  .  .  . push-arg
  0:0008: 13 01  .  .  . gref [val,]*
  0:0010: 1b  .  .  .  . apply-cont
  0:end
  ()
  bce> 
```

## Installing

The compiler based system can be installed or used from the build directory.
To install:
```
   $ sudo make install
```

The escheme entry is stored in /usr/local/bin which should be included in the path. It can
be invoked without path qualification. See Running.

The escheme system can be removed just as easily.
```
   $ sudo make uninstall
```

