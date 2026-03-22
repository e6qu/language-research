# 02-hello-web-server (Common Lisp)

Minimal HTTP server using SBCL's built-in `sb-bsd-sockets` (no external dependencies).

## Endpoints

- `GET /greet` - returns "Hello, world!"
- `GET /greet?name=Alice` - returns "Hello, Alice!"
- `GET /health` - returns `{"status":"ok"}`

## Usage

```bash
make test        # unit tests
make e2e         # end-to-end test
bash run.sh      # start server on :8080
curl http://localhost:8080/greet?name=Lisp
```

## Notes

- Uses `sb-bsd-sockets` directly, avoiding Quicklisp dependencies.
- `unwind-protect` is CL's equivalent of try/finally.
- The condition system could provide restarts for socket errors, but is beyond this tutorial's scope.
