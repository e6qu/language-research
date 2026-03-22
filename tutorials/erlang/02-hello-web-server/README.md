# 02 - Hello Web Server

Minimal Erlang web server using Cowboy and JSX for JSON responses.

## Routes

| Method | Path           | Response                              |
|--------|----------------|---------------------------------------|
| GET    | `/`            | `{"message": "Hello, world!"}`        |
| GET    | `/greet/:name` | `{"message": "Hello, <name>!"}`       |
| *      | `/[...]`       | `{"error": "not found"}` (404)        |

## Run

```bash
chmod +x run.sh && ./run.sh
```

To start the server interactively:

```bash
rebar3 shell
```

Then visit `http://localhost:8080/`.

## Test

```bash
rebar3 eunit -v
```
