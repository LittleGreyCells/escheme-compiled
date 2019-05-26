escheme _compiled_
================

A scheme interpreter with compilation system

## Introduction

escheme is an aspiring R3RS implementation of the algorithmic language scheme, 
supporting approximately 90% of the standard. It has been principally an experimental
testbed for exploring models of evaluation, interpreter design and construction.
Along the way escheme has become a respectible programming language, not a toy.
Many additional functions are added to support environments, input/output, the host OS 
(linux/unix) and access escheme internals. Bignums are not supported.

Abelson and Sussman's SICP* in Ch5 describes an explicit control evalutor for 
scheme. That material provided the impetus for escheme. It is not related to
emacs or eLisp in any way.

SICP (Ch5) also describes an abstract machine and a compiler to transform 
scheme expressions into executable code. escheme _compiled_ also runs
with that idea, creating its own abstract machine which closely parallels the
interpreter core, but eliminating the interpreter's repeated analysis.

(*) Structure and Interpretation of Computer Programs (aka SICP)
    by Harold Abelson and Gerald Sussman
    MIT Press (1984)

## Two Worlds

In escheme _compiled_ evaluation can move freely between the interpreter's explict control 
evaluator and the compiler's targeted byte code evaluator. This is a SICP goal realized and
offers the developer the option of choosing intepretation during development
and compilation for system delivery.

escheme boots into the compiler, but is also configured to boot into the interpreter.

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
