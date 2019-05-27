escheme _compiled_
================

The escheme interpreter with compilation system

## Introduction

See escheme.

_SICP_ also describes an abstract machine and a compiler to transform 
scheme expressions into executable code. This second implementation of escheme runs
with that idea, creating an abstract machine which closely parallels the
interpreter core, but eliminating the interpreter's repeated analysis.

## Two Worlds

A _dyad_ is defined as "two individuals or units regarded as a pair." escheme _compiled_ evaluation 
can move freely between the interpreter's explict control evaluator and the compiler's targeted 
byte code evaluator. This flexibility offers the developer the option of choosing 
intepretation during development and compilation for system delivery.

escheme _compiled_ by default boots into the read-compile-eval-print loop, but can also 
be configured to boot into the interpreter's read-eval-print loop. 

## Implementation 

escheme is implemented in C++11, using a modest set of language features
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

## Extending escheme

See _docs/bindings_guide.txt_ to learn how to extend escheme with additional 
primitives implemented in C++. It covers both passing escheme 
values and constructing simple or structured objects (lists and vectors) to
return back to escheme.

## Getting Started

Consult the file _BuildingAndRunning_ to build the interpreter/compiler. Run as an 
interpeter or reconfigure the system to run a read/compile/eval/print loop.

For a complete list of escheme functions (and a help system) consult syntax.scm/syntax-help.scm in the 
root directory.
