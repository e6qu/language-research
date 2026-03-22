# 01-hello-world (Common Lisp)

Minimal greeting library using SBCL.

## Layout

```
src/hello.lisp   - greet function in its own package
test/run.lisp    - assertion-based tests
Makefile         - build/test/e2e/fatbin targets
run.sh           - quick run script
```

## Usage

```bash
make build       # load-compile check
make test        # run tests
make e2e         # end-to-end check
make fatbin      # standalone executable (~50-80 MB, includes SBCL runtime)
```

## Notes

- Common Lisp uses `defpackage` for namespacing and `format` for string interpolation.
- `format nil ...` returns a string; `format t ...` prints to stdout.
- The condition system (conditions + restarts) is CL's unique error-handling mechanism,
  far more powerful than try/catch, but not needed for this tutorial.
