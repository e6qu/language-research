# Scheme — Minimal Lisp, Maximum Elegance

## Overview

Scheme is a minimalist dialect of Lisp, created by Guy Steele and Gerald Sussman at MIT
in 1975. It was the first Lisp to adopt lexical scoping and the first to require tail-call
optimization. The language is standardized as R7RS (Revised^7 Report on the Algorithmic
Language Scheme, ratified 2013), split into R7RS-small (minimal) and R7RS-large (batteries
included, still in progress).

- **Standard**: R7RS-small (2013), R7RS-large (in progress)
- **Paradigm**: Functional, imperative, meta-programming (macros)
- **Typing**: Dynamic, strong (latent typing)
- **Execution**: Varies by implementation — compiled, interpreted, or JIT
- **Package manager**: Varies by implementation (no universal standard)
- **GC**: Yes (all implementations)

### Design Philosophy
Scheme's philosophy is "less is more." The core language is tiny — a page of syntax rules —
but extraordinarily powerful because of closures, continuations, tail calls, and hygienic
macros. The idea is to provide a small number of orthogonal, composable primitives from
which anything can be built. Scheme trusts the programmer to build abstractions rather
than providing them built-in.

## Core Language Features

### S-Expressions — Code Is Data
```scheme
;; Everything is a list. Code and data share the same structure.
(define (square x) (* x x))      ; function definition
(map square '(1 2 3 4 5))        ; => (1 4 9 16 25)

;; Quoting prevents evaluation — gives you the data structure
'(+ 1 2)     ; => the list (+ 1 2), not 3
(eval '(+ 1 2))  ; => 3 — evaluate data as code
```

### First-Class Functions & Closures
```scheme
;; Lambda — anonymous functions
(define add (lambda (a b) (+ a b)))

;; Higher-order functions
(define (compose f g)
  (lambda (x) (f (g x))))

(define inc-then-double (compose (lambda (x) (* x 2))
                                  (lambda (x) (+ x 1))))
(inc-then-double 3)  ; => 8

;; Closures capture their environment
(define (make-counter)
  (let ((count 0))
    (lambda ()
      (set! count (+ count 1))
      count)))

(define c (make-counter))
(c)  ; => 1
(c)  ; => 2
(c)  ; => 3
```

### Let Bindings & Scope
```scheme
;; let — parallel bindings
(let ((x 1) (y 2))
  (+ x y))  ; => 3

;; let* — sequential bindings (each can see previous)
(let* ((x 1) (y (+ x 1)))
  (+ x y))  ; => 3

;; letrec — recursive bindings
(letrec ((even? (lambda (n) (if (= n 0) #t (odd? (- n 1)))))
         (odd?  (lambda (n) (if (= n 0) #f (even? (- n 1))))))
  (even? 10))  ; => #t
```

## Tail-Call Optimization

Scheme *requires* implementations to optimize tail calls. This is not optional — it is in
the specification. This means recursion is as efficient as iteration.

```scheme
;; This will NOT stack overflow, no matter how large n is
(define (factorial n)
  (define (loop n acc)
    (if (= n 0)
        acc
        (loop (- n 1) (* acc n))))  ; tail position — optimized
  (loop n 1))

(factorial 1000000)  ; Works — constant stack space

;; Tail-recursive map
(define (my-map f lst)
  (let loop ((rest lst) (acc '()))
    (if (null? rest)
        (reverse acc)
        (loop (cdr rest) (cons (f (car rest)) acc)))))
```

- Every Scheme implementation MUST optimize tail calls (R5RS onward)
- Loops are expressed as tail-recursive functions — no separate loop construct needed
- Named `let` (shown above) is idiomatic for loop-like patterns
- `do` form exists but named `let` is preferred

## Continuations

Scheme exposes continuations as first-class values via `call/cc`
(`call-with-current-continuation`). A continuation represents "the rest of the
computation" — it captures the entire execution context.

```scheme
;; Basic call/cc — capture the continuation
(define saved-k #f)

(+ 1 (call/cc (lambda (k)
                (set! saved-k k)  ; save the continuation
                10)))             ; => 11

(saved-k 20)  ; => 21 — resumes computation with 20 instead of 10

;; Implementing exceptions with continuations
(define (with-exception-handler handler thunk)
  (call/cc (lambda (exit)
    (thunk (lambda (error) (exit (handler error)))))))

(with-exception-handler
  (lambda (e) (string-append "Error: " e))
  (lambda (throw)
    (throw "something went wrong")))
; => "Error: something went wrong"
```

**What continuations enable**:
- Exceptions / non-local exits
- Coroutines and cooperative multitasking
- Backtracking search (amb operator)
- Web server session continuations (Seaside-style)
- Generators / iterators
- Delimited continuations (more structured: `shift`/`reset`)

Continuations are Scheme's most powerful and most confusing feature. Most languages
implement specific control flow mechanisms; Scheme provides the primitive from which all
of them can be built.

## Hygienic Macros

Scheme's macro system is *hygienic* — macros cannot accidentally capture or shadow
variables from the use site. This is fundamentally different from Common Lisp's macros.

### syntax-rules — Pattern-Based Macros (R5RS+)
```scheme
;; Pattern matching on syntax
(define-syntax my-when
  (syntax-rules ()
    ((my-when test body ...)
     (if test (begin body ...)))))

(my-when (> 3 2)
  (display "yes")
  (newline))

;; Anaphoric-style macro — safe due to hygiene
(define-syntax swap!
  (syntax-rules ()
    ((swap! a b)
     (let ((tmp a))
       (set! a b)
       (set! b tmp)))))
;; tmp cannot conflict with user variables — hygiene guarantees this
```

### syntax-case — Procedural Hygienic Macros (R6RS)
```scheme
;; More powerful — full Scheme at macro expansion time
(define-syntax my-let
  (lambda (stx)
    (syntax-case stx ()
      ((_ ((var expr) ...) body ...)
       #'((lambda (var ...) body ...) expr ...)))))
```

- `syntax-rules` — declarative, pattern-based, simple (R5RS, R7RS)
- `syntax-case` — procedural, full Scheme power at expand time (R6RS)
- Hygiene prevents variable capture bugs that plague Common Lisp macros
- Trade-off: hygienic macros are safer but less flexible for some patterns
- Breaking hygiene is possible when needed (`datum->syntax`)

## Major Implementations

### Chez Scheme
- **Speed**: One of the fastest Scheme implementations. Native code compiler.
- **Standard**: R6RS primarily
- **Developed by**: R. Kent Dybvig; now maintained by Cisco (open-sourced 2016)
- **Current version**: 10.3.0 (2025)
- **Notable**: Powers Racket's backend (Racket-on-Chez)
- **Platforms**: Linux, macOS, Windows, *BSD

### Guile
- **Role**: GNU's official extension language (like Lua for GNU)
- **Current version**: 3.0.11
- **Features**: JIT compiler (3.0+), good performance, POSIX integration
- **Standard**: R5RS + R6RS modules + R7RS in progress
- **Used by**: GNU Guix (package manager), GDB, GIMP (scripting), GNU Make
- **Interop**: C FFI, can embed in C applications

### Chicken Scheme
- **Compiles to C** — generates portable C code, then uses system C compiler
- **Current version**: Chicken 5.x
- **Standard**: R5RS core, R7RS via extension
- **Package manager**: `chicken-install` (eggs repository, ~800+ eggs)
- **Notable**: Practical for real-world apps, good FFI, compiles to standalone binaries
- **Performance**: Good — ahead-of-time compilation via C

### Gambit
- **Native code compiler** — generates C, can target many platforms
- **Standard**: R5RS, R7RS partial
- **Performance**: Very fast, competitive with Chez
- **Notable**: Targets iOS, Android, JavaScript, Python via C output

### Racket (Extended Scheme)
- **Not strictly Scheme** — evolved beyond R6RS into its own language
- **Current version**: 8.x (2025)
- **Features**: Full IDE (DrRacket), massive standard library, typed variant (Typed Racket)
- **Macro system**: More powerful than R7RS — syntax objects, phases, modules
- **Package manager**: `raco pkg` (~2,500+ packages)
- **Used for**: Teaching, research, language-oriented programming
- **Notable**: DrRacket IDE is one of the best Lisp development environments

### Other Notable Implementations
- **Chibi-Scheme** — small, embeddable R7RS implementation (~40K binary)
- **MIT/GNU Scheme** — historic, used with SICP
- **S7** — embeddable Scheme for audio (used in Snd, Scheme for Max)
- **Larceny** — research implementation, full R7RS + extensive SRFI support

## SRFI — Scheme Requests for Implementation

SRFIs are Scheme's answer to the "no standard library" problem. They are community
proposals for portable library interfaces.

```scheme
;; Using SRFI-1 (list library)
(import (srfi 1))
(filter odd? '(1 2 3 4 5))   ; => (1 3 5)
(fold + 0 '(1 2 3 4 5))      ; => 15

;; Using SRFI-9 (records)
(import (srfi 9))
(define-record-type <point>
  (make-point x y)
  point?
  (x point-x)
  (y point-y))
```

- ~250 SRFIs defined (https://srfi.schemers.org/)
- Implementation support varies — Chibi, Larceny, Chicken have broad coverage
- Key SRFIs: 1 (lists), 9 (records), 41 (streams), 69 (hash tables), 113 (sets)

## Error Handling

```scheme
;; R7RS exception handling
(import (scheme base))

(guard (exn
        ((string? (condition/message exn))
         (display "Error: ")
         (display (condition/message exn))))
  (error "something broke" "details"))

;; with-exception-handler for lower-level control
(with-exception-handler
  (lambda (e) (display "caught!"))
  (lambda () (raise "oops"))
  #:unwind? #t)  ; Racket-style; varies by implementation
```

- `guard` — R7RS standard exception handling (catch + test)
- `raise` / `error` — signal exceptions
- `with-exception-handler` — install exception handlers
- Continuations can also implement exception-like control flow
- No condition/restart system (that's Common Lisp)

## SICP — The Teaching Legacy

Scheme's most lasting impact may be as the teaching language for *Structure and
Interpretation of Computer Programs* (SICP) by Abelson and Sussman. For decades, MIT's
introductory CS course (6.001) used Scheme and SICP.

- SICP teaches fundamental CS concepts: recursion, abstraction, interpreters, metalinguistic abstraction
- Scheme's minimalism means students focus on concepts, not syntax
- MIT replaced SICP with Python in 2009, but the book remains influential
- Many universities still use Scheme/Racket for PL courses
- SICP freely available at https://mitpress.mit.edu/sites/default/files/sicp/

## Concurrency

Scheme has no standard concurrency model — it varies by implementation:

- **Guile**: POSIX threads + fibers (cooperative via delimited continuations)
- **Chez**: Native OS threads, thread-safe
- **Racket**: Green threads (places for parallelism, threads for concurrency, futures for speculative)
- **Chicken**: SRFI-18 threads (cooperative, single-core)
- **Gambit**: SRFI-18 threads

## Comparison with Common Lisp

| Aspect | Scheme | Common Lisp |
|---|---|---|
| **Size** | Minimal (~50 pages for R7RS-small) | Large (~1,000+ page ANSI spec) |
| **Philosophy** | Less is more — build from primitives | Batteries included |
| **Macros** | Hygienic (syntax-rules/case) | Unhygienic (defmacro, more flexible) |
| **Tail calls** | Required by spec | Not required (SBCL does it anyway) |
| **Continuations** | First-class (call/cc) | No first-class continuations |
| **Namespace** | Lisp-1 (single namespace) | Lisp-2 (separate function/value) |
| **OOP** | Not built-in (many OOP libraries) | CLOS (powerful, standard) |
| **Error handling** | guard/raise | Condition/restart (more powerful) |
| **Implementations** | Many, fragmented | Few, mature (SBCL dominates) |
| **Standard library** | Minimal (SRFIs fill gaps) | Rich (400+ functions in spec) |

## Comparison with Racket

| Aspect | Scheme (R7RS) | Racket |
|---|---|---|
| **Standard** | R7RS spec, multiple implementations | Single implementation |
| **Macro system** | syntax-rules / syntax-case | More advanced (syntax objects, phases) |
| **Library** | Minimal + SRFIs | Massive built-in library |
| **IDE** | Editor-dependent | DrRacket (excellent) |
| **Teaching** | SICP tradition | How to Design Programs (HtDP) |
| **Typed variant** | Implementation-specific | Typed Racket (gradual typing) |
| **Package manager** | Implementation-specific | `raco pkg` (~2,500 packages) |

## Strengths

- **Minimal core** — the entire language fits in your head
- **Tail-call optimization** — guaranteed by the spec, recursion as efficient as loops
- **Continuations** — the most powerful control flow primitive in any language
- **Hygienic macros** — safe metaprogramming without variable capture bugs
- **Teaching language** — SICP, HtDP, countless university courses
- **Embeddable** — Chibi (~40K), S7, Guile are designed for embedding
- **Conceptual clarity** — closures, continuations, and macros from first principles
- **Multiple quality implementations** — Chez (speed), Guile (GNU ecosystem), Chicken (practical), Racket (batteries)

## Weaknesses

- **Fragmented ecosystem** — no single dominant implementation (unlike SBCL for CL)
- **No standard library** — SRFIs help but portability between implementations is hard
- **R7RS-large still incomplete** — the "batteries included" standard is stalled
- **Small community** — fewer jobs, fewer production deployments than most languages
- **Parentheses** — barrier to entry (though Lisp programmers stop seeing them quickly)
- **No standard concurrency** — each implementation does it differently
- **Dynamic typing** — no compile-time type safety (Typed Racket is the exception)
- **Limited industry adoption** — mostly academic and embedded scripting

## Notable Uses

| Project/Context | Implementation | Description |
|---|---|---|
| **SICP** | MIT Scheme | The most influential CS textbook |
| **GNU Guix** | Guile | Functional package manager and OS distro |
| **GDB** | Guile | Scripting for GNU Debugger |
| **GIMP** | Script-Fu (TinyScheme) | Image manipulation scripting |
| **Nanopass Framework** | Chez Scheme | Compiler construction framework |
| **Unison** | — | Language influenced by Scheme concepts |
| **Haskell** | — | Continuations influenced Haskell's design |

## When to Choose Scheme

- **Teaching CS fundamentals** — recursion, abstraction, interpreters, language design
- **Embedding a scripting language** — Chibi, Guile, S7 are small and embeddable
- **GNU ecosystem extension** — Guile is the standard GNU extension language
- **Language research** — Scheme's simplicity makes it ideal for PL experiments
- **When you want minimal** — if you want the smallest possible Lisp that is still powerful
- **Macro experimentation** — hygienic macros are a unique and powerful system
