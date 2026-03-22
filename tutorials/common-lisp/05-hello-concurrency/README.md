# 05-hello-concurrency (Common Lisp)

Thread-safe counter, fan-out parallelism, and pipeline using SBCL threads.

## Patterns

- **Counter**: `sb-thread:make-mutex` + `sb-thread:with-mutex` for safe shared state
- **Fan-out**: Spawn threads, join all, collect results
- **Pipeline**: Chain stages, each in its own thread

## Usage

```bash
make test
bash run.sh
```

## Notes

- SBCL provides `sb-thread` for native OS threads (pthreads on Linux/macOS).
- `bordeaux-threads` is the portable library, but `sb-thread` avoids Quicklisp for this tutorial.
- The condition system can signal conditions across threads, but thread error handling here uses `unwind-protect`.
