# Common Lisp — Industrial-Strength Lisp

## Overview

Common Lisp (CL) is a multi-paradigm, dynamically typed programming language standardized
by ANSI in 1994 (ANSI INCITS 226-1994). It unifies several earlier Lisp dialects into a
large, practical language with a rich standard library. CL emphasizes interactive
development, metaprogramming via macros, and a uniquely powerful condition/restart
error-handling system.

- **Standard**: ANSI Common Lisp (1994, stable — the spec is frozen)
- **Paradigm**: Multi-paradigm — functional, imperative, OOP (CLOS), generic, meta
- **Typing**: Dynamic, strong (with optional type declarations for optimization)
- **Execution**: Compiled to native code (SBCL), bytecode, or interpreted
- **Package manager**: Quicklisp (~1,500 libraries), Ultralisp, OCICL
- **GC**: Yes (generational in SBCL)

### Design Philosophy
Common Lisp is pragmatic, not minimal. Where Scheme says "give me the smallest set of
primitives," CL says "give me everything I need to ship production software." The spec
includes 978 symbols — hash tables, pathnames, pretty printer, format strings, CLOS,
conditions, and more. The language is designed to be extended by the programmer via macros,
making CL a "programmable programming language."

## CLOS — Common Lisp Object System

CLOS is the standard OOP system in Common Lisp. It is fundamentally different from
class-based OOP in Java/Python/C++.

```lisp
;; Classes
(defclass animal ()
  ((name :initarg :name :accessor animal-name)
   (sound :initarg :sound :accessor animal-sound)))

(defclass dog (animal)
  ((breed :initarg :breed :accessor dog-breed))
  (:default-initargs :sound "woof"))

;; Generic functions — methods belong to functions, not classes
(defgeneric speak (animal))

(defmethod speak ((a animal))
  (format t "~A says ~A~%" (animal-name a) (animal-sound a)))

(defmethod speak ((d dog))
  (format t "~A (~A) says ~A~%" (animal-name d) (dog-breed d) (animal-sound d)))

;; Multiple dispatch — method selected on ALL argument types
(defgeneric encounter (a b))

(defmethod encounter ((a dog) (b dog))
  (format t "~A and ~A sniff each other~%" (animal-name a) (animal-name b)))

(defmethod encounter ((a animal) (b animal))
  (format t "~A and ~A ignore each other~%" (animal-name a) (animal-name b)))
```

**What makes CLOS different**:
- **Multiple dispatch** — methods dispatch on the types of ALL arguments, not just `this`/`self`
- **Methods belong to generic functions**, not to classes
- **Method combinations** — `:before`, `:after`, `:around` methods for aspect-oriented patterns
- **MOP (Meta-Object Protocol)** — the object system itself is extensible and programmable
- **No encapsulation enforcement** — slots are accessible; convention over restriction
- **Change class at runtime** — `change-class` can morph an object to a different class

### Method Combinations
```lisp
(defmethod speak :before ((a animal))
  (format t "[About to speak] "))

(defmethod speak :after ((a animal))
  (format t "[Done speaking]~%"))

(defmethod speak :around ((d dog))
  (format t ">>> ")
  (call-next-method)  ; calls the primary method
  (format t " <<<"))
```

## Condition/Restart System — Unique Error Handling

CL's condition system is arguably its most distinctive feature. Unlike exceptions
(which unwind the stack immediately), conditions allow the *handler* to decide how to
*restart* the computation — without unwinding.

```lisp
;; Define a condition (like an exception type)
(define-condition malformed-entry (error)
  ((text :initarg :text :reader entry-text)))

;; Define restarts — recovery strategies offered by low-level code
(defun parse-entry (text)
  (restart-case
      (if (valid-entry-p text)
          (do-parse text)
          (error 'malformed-entry :text text))
    ;; Restarts — the caller chooses which one to invoke
    (skip-entry ()
      :report "Skip this entry"
      nil)
    (use-value (value)
      :report "Use a replacement value"
      value)
    (reparse (new-text)
      :report "Supply corrected text"
      (parse-entry new-text))))

;; High-level code decides recovery strategy WITHOUT knowing internals
(defun process-file (path)
  (handler-bind
      ((malformed-entry
        (lambda (c)
          (format t "Bad entry: ~A, skipping~%" (entry-text c))
          (invoke-restart 'skip-entry))))
    (mapcar #'parse-entry (read-entries path))))
```

**Why this is unique**:
- **No stack unwinding** — the handler runs *between* the error site and the restart
- **Separation of policy and mechanism** — low-level code defines HOW to recover (restarts); high-level code decides WHICH recovery to use (handlers)
- **Interactive debugging** — when no handler matches, the debugger shows all available restarts; you choose one interactively
- **Retryable operations** — you can fix the problem and retry from the exact point of failure
- No other mainstream language has this. Erlang's supervisors solve a similar problem (recovery without crashing) but at the process level, not the call-stack level.

## Macros — The Programmable Programming Language

CL macros operate on the AST (s-expressions) before compilation. They are unhygienic
(unlike Scheme) but maximally powerful.

```lisp
;; Simple macro
(defmacro when-let ((var expr) &body body)
  `(let ((,var ,expr))
     (when ,var ,@body)))

(when-let (user (find-user 42))
  (format t "Found: ~A~%" (user-name user)))
;; Expands to:
;; (let ((user (find-user 42)))
;;   (when user (format t "Found: ~A~%" (user-name user))))

;; Domain-specific language via macros
(defmacro with-html-output (stream &body body)
  `(progn ,@(generate-html body stream)))

;; Compile-time computation
(defmacro define-routes (&body routes)
  `(list ,@(loop for (method path handler) in routes
                 collect `(make-route ,method ,path #',handler))))

(define-routes
  (:get  "/users"     list-users)
  (:post "/users"     create-user)
  (:get  "/users/:id" get-user))
```

- Backquote (`` ` ``), comma (`,`), and splice (`,@`) for template construction
- `gensym` to avoid variable capture (manual hygiene)
- Macros can generate other macros, inspect types, call arbitrary functions
- `macroexpand-1` and `macroexpand` for debugging macro expansion
- Reader macros can extend the syntax itself (e.g., `#/regex/` syntax)

## REPL-Driven Development

CL development is fundamentally interactive. You don't edit-compile-run; you develop
inside a running image.

```lisp
;; In SLIME/Sly (Emacs) or SLY:
;; 1. Start SBCL with your project loaded
;; 2. Edit a function in your editor
;; 3. Press C-c C-c to compile JUST that function into the running image
;; 4. Test immediately at the REPL
;; 5. If it errors, the debugger shows the stack + restarts
;; 6. Fix the function, recompile, invoke the restart to retry
;; 7. The server never stopped running

CL-USER> (defun greet (name) (format nil "Hello, ~A!" name))
GREET
CL-USER> (greet "World")
"Hello, World!"
CL-USER> (greet 42)  ; works — format coerces
"Hello, 42!"
```

**Development tools**:
- **SLIME** (Emacs) — Superior Lisp Interaction Mode for Emacs. The gold standard
- **SLY** (Emacs) — modern fork of SLIME
- **Alive** (VS Code) — CL extension for VS Code
- **Lem** — Emacs-like editor written in CL, with built-in CL support

## Image-Based Development

CL runs inside an "image" — a heap dump of the entire running system. You can save
and restore the complete state of a program.

```lisp
;; Save the current running state as an executable
(sb-ext:save-lisp-and-die "my-server"
  :toplevel #'main
  :executable t
  :compression t)
```

- The saved image contains ALL loaded code, data, and state
- Restart exactly where you left off — including CLOS instances, hash tables, closures
- Deploy by shipping one file (no dependency installation needed)
- **Binary size**: ~50-80 MB for SBCL images (compression helps, but still large)
- This is fundamentally different from most languages — your program IS a running world

**Trade-offs**:
- Pros: Fast startup of pre-loaded code, reproducible deployment, inspectable state
- Cons: Large binaries (~50-80 MB), hard to containerize minimally, opaque to traditional tools

## Major Implementations

### SBCL (Steel Bank Common Lisp)
- **The dominant implementation** — most production CL code runs on SBCL
- **Current version**: 2.6.2 (February 2026), monthly releases
- **Compilation**: Native code compiler, excellent optimization
- **Performance**: Competitive with Java/Go for many workloads
- **Platforms**: Linux, macOS, Windows, FreeBSD (x86-64, ARM64)
- **Features**: Generational GC, type inference, inline assembly, profiler
- **Active development**: Monthly releases for 20+ years

### CCL (Clozure Common Lisp)
- Native code compiler, fast compilation
- Good macOS support (historically the best CL on Mac)
- Multi-threaded, conservative GC
- Less optimized than SBCL but faster compile times

### ECL (Embeddable Common Lisp)
- Compiles to C — can embed CL in C/C++ applications
- Smaller footprint than SBCL/CCL
- Good for embedding, less suitable for high-performance standalone apps

### Other
- **ABCL** — runs on JVM, Java interop
- **Clasp** — compiles to LLVM, C++ interop (designed for scientific computing)
- **LispWorks** — commercial, GUI builder, good IDE (proprietary)
- **Allegro CL** — commercial, enterprise features (Franz Inc.)

## Type System

CL is dynamically typed but supports optional type declarations for optimization:

```lisp
;; Dynamic typing — types checked at runtime
(defun add (a b) (+ a b))
(add 1 2)      ; => 3
(add 1.0 2)    ; => 3.0
(add "a" "b")  ; ERROR — runtime type error

;; Optional type declarations — help the compiler optimize
(defun fast-add (a b)
  (declare (type fixnum a b))
  (declare (optimize (speed 3) (safety 0)))
  (the fixnum (+ a b)))

;; SBCL's type inference catches many errors at compile time
(defun broken (x)
  (declare (type string x))
  (+ x 1))  ; SBCL warns: X is STRING, not NUMBER
```

- Dynamic by default — flexibility for rapid development
- `declare` and `the` for type hints — compiler uses them for optimization + warnings
- SBCL's type inference is surprisingly powerful — catches many type errors at compile time
- No Hindley-Milner — types are advisory, not enforced (at safety > 0, runtime checks apply)

## Concurrency

```lisp
;; Bordeaux Threads — portable threading library
(bt:make-thread (lambda () (format t "Hello from thread~%")))

;; Lparallel — parallel programming library
(lparallel:pmap #'expensive-fn data)

;; Channels (lparallel)
(let ((ch (lparallel:make-channel)))
  (lparallel:submit-task ch (lambda () (compute-result)))
  (lparallel:receive-result ch))
```

- **Bordeaux Threads (bt)** — portable thread API across implementations
- **Lparallel** — parallel map, futures, promises, channels, task queues
- **Atomics** — `sb-ext:atomic-incf` etc. in SBCL
- **No green threads / actor model** — OS threads only (unlike BEAM/Go)
- **cl-async** — event-loop-based async I/O (libuv)

## Web & Networking

- **Hunchentoot** — mature HTTP/1.1 server (the "Apache of CL")
- **Clack** — Rack/WSGI-like HTTP abstraction layer
- **Caveman2** — web framework on Clack
- **Ningle** — micro web framework (Sinatra-like)
- **Dexador** — HTTP client (fast, supports connection pooling)
- **Woo** — high-performance HTTP server (libev-based, benchmarks well)
- **cl-json / jonathan / jzon** — JSON parsing/generation

## CLI & Binary Distribution

```lisp
;; Build a standalone executable
(sb-ext:save-lisp-and-die "myapp"
  :toplevel #'main
  :executable t
  :compression 9)  ; zstd compression

;; CLI argument parsing
(ql:quickload :clingon)  ; or unix-opts, adopt
```

| Method | Size | Notes |
|---|---|---|
| `save-lisp-and-die` (SBCL) | ~50-80 MB | Full runtime + your code. Compression to ~20-30 MB |
| `save-lisp-and-die` + tree shaking | ~20-40 MB | Experimental, removes unused code |
| ECL (compile to C) | ~5-15 MB | Smaller but slower runtime |
| ABCL (JVM jar) | ~30 MB + JVM | Needs JVM installed |

The large binary size is CL's biggest deployment disadvantage compared to Go (~10 MB),
Rust (~1-5 MB), or Zig (~100 KB).

## Package Management

```bash
# Quicklisp — the standard package manager
# Install (one-time):
curl -O https://beta.quicklisp.org/quicklisp.lisp
sbcl --load quicklisp.lisp --eval '(quicklisp-quickload:install)'

# In the REPL:
(ql:quickload :alexandria)     ; load a library
(ql:system-apropos "json")     ; search for libraries
```

- **Quicklisp** — ~1,500 libraries, monthly dist updates, "it just works"
- **Ultralisp** — faster update cycle than Quicklisp (community-run)
- **OCICL** — newer alternative with better CI integration
- **ASDF** — the build system (Another System Definition Facility), bundled with all implementations

## Notable Projects & Users

| Project / Company | Description |
|---|---|
| **Grammarly** | Core grammar engine written in CL (serves millions of users daily) |
| **ITA Software / Google Flights** | QPX fare search engine — CL powering flight searches |
| **pgloader** | PostgreSQL data migration tool — rewritten from Python to CL for 20-30x speedup |
| **Hacker News** | Runs on Arc (a Lisp dialect built on Racket, heavily CL-influenced) |
| **Coalton** | Typed functional language embedded in CL (Haskell-like types + CL macros) |
| **Lem** | Emacs-like editor written entirely in CL |
| **Stumpwm** | Tiling window manager written in CL |
| **Maxima** | Computer algebra system (one of the oldest CL programs, since the 1960s) |
| **ACL2** | Theorem prover used in hardware verification (AMD, Intel) |
| **Nyxt** | Web browser written in CL (Emacs-like extensibility) |

### Grammarly Deep Dive
Grammarly's core grammar checking engine is written in Common Lisp. As of their
engineering blog posts, CL handles the linguistic analysis, rule engine, and NLP pipeline.
The CL code is highly optimized and handles millions of requests. They use SBCL in
production.

### ITA Software / Google Flights
ITA Software built QPX, a flight search engine, in Common Lisp in the early 2000s. Google
acquired ITA in 2010 for $700M. The CL-based QPX engine powered Google Flights for years,
though Google has been gradually migrating components to other languages.

## Performance

- **SBCL**: Competitive with Java and Go for many workloads
- **Type declarations** + `(optimize (speed 3))` can approach C performance for numerical code
- **Generational GC**: Sub-millisecond pauses for most workloads
- **Compilation**: SBCL compiles to native code — no interpreter overhead
- **Startup**: ~50ms for SBCL (image load), or instant if using a pre-built image

## Strengths

- **Condition/restart system** — error handling that no other language matches
- **CLOS** — multiple dispatch, method combinations, MOP
- **Macros** — the most powerful metaprogramming system in any mainstream language
- **REPL-driven development** — modify running programs interactively
- **Image-based development** — save and restore complete program state
- **Mature and stable** — the ANSI spec hasn't changed since 1994; code from the 1990s still runs
- **SBCL quality** — excellent native code compiler, monthly releases for 20+ years
- **Interactive debugging** — the debugger + restarts make fixing bugs uniquely pleasant

## Weaknesses

- **Large binaries** — 50-80 MB for save-lisp-and-die images
- **Small community** — niche language, fewer jobs than mainstream options
- **Dynamic typing** — no compile-time safety guarantees (type declarations help but are optional)
- **Library ecosystem** — ~1,500 Quicklisp libraries vs 150K+ for npm/pip/crates
- **Parentheses** — barrier to adoption (though experienced Lispers don't notice them)
- **No standard concurrency** — Bordeaux Threads is portable but basic; no green threads
- **Unicode** — historically weak; improving but not as seamless as modern languages
- **Tooling outside Emacs** — SLIME/SLY on Emacs is excellent; everything else is worse
- **Perception** — seen as "dead" or "academic" despite active production use

## When to Choose Common Lisp

- **Complex domain logic** — macros let you build DSLs that match the problem domain
- **Interactive/exploratory development** — REPL-driven workflow is unmatched
- **Systems requiring novel error recovery** — the condition/restart system shines
- **Long-lived, evolving systems** — image-based development, stable spec, 30-year-old code runs fine
- **When you need CLOS** — multiple dispatch and method combinations for complex OOP
- **Prototyping** — dynamic typing + REPL = very fast iteration
- **When you value programmer happiness** — CL developers tend to be extremely productive and satisfied
