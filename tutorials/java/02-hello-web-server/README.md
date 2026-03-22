# 02-hello-web-server

HTTP server using JDK built-in `com.sun.net.httpserver.HttpServer`.

## Routes

- `GET /` -- returns "Hello, World!"
- `GET /greet/{name}` -- returns "Hello, {name}!"

## Run

```bash
bash run.sh        # port 8080
bash run.sh 9090   # custom port
```

## Test

```bash
make test
```
