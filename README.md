escheme _compiled_
================

The _escheme_ interpreter with compilation system

## Introduction

_SICP_ also describes an abstract machine and a compiler to transform 
scheme expressions into executable code. This second implementation of _escheme_ runs
with that idea, creating an abstract machine which closely parallels the
interpreter core, but eliminating the interpreter's repeated analysis.

## Two Worlds

"dyad" -- consisting of two elements or parts

Evaluation can move freely between the interpreter's explict 
control evaluator (ECE) and the compiler's targeted byte code evaluator (BCE). This flexibility 
offers the developer the option of choosing intepretation during development and 
compilation for system delivery.

_escheme compiled_ by default boots into the read-compile-eval-print loop, but can also 
be configured to boot into the interpreter's read-eval-print loop, if invoked with the 
"-i/--interpreter" argument. The compiler's source
can be loaded, modified, reloaded to support compiler developement. The imager can be
loaded (see ./imager) and used to generate a new compiler image which subsequently
can be used to boot into BCE mode.

## Implementation 

_escheme_ is implemented in C++14, using a modest set of language features
exploiting class initialization/finalization semantics for deferred execution 
and cleanup. Templates are used for control stack and argument stack 
implementation. Exceptions are used for non-local returns, 
while honoring C++ block finalization.

### Content
  
| Directory        | Description                                        |
| ---------------- | ---------------------------------------------------|
|  src/eval    |    dual evaluators (explicit control and byte code)|
|  src/core    |    core sources|
|  src/linenoise|  readline package|
|  compiler  | compiler and compiled image |
|  imager | image creator and loader |
|  macros   |  macro and quasiquote for interpreter and compiler |
|  boot | bootstrapping files for interpreter or compiler REP loops|
|  tests  |    files for escheme regression testing|
|  docs |      documentation which may or may not be accurate|
|  help |      escheme syntax related files|

## Extending escheme

See _docs/bindings_guide.txt_ to learn how to extend _escheme_ with additional 
primitives implemented in C++. It covers both passing _escheme_ 
values and constructing simple or structured objects (lists and vectors) to
return back to _escheme_.

## Getting Started

Consult the file _BuildingAndRunning_ to build the interpreter/compiler. Run as an 
interpeter or reconfigure the system to run a read/compile/eval/print loop.

For a complete list of _escheme_ functions (and a help system) consult syntax-help.scm in the 
help directory.
