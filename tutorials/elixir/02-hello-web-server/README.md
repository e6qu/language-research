# 02 - Hello Web Server

A minimal Elixir web server using Plug and Bandit.

## What you'll learn

- Defining routes with `Plug.Router`
- Returning JSON responses with `Jason`
- Running a web server with `Bandit`
- Testing routes with `Plug.Test`

## Project structure

```
lib/hello_web/
  application.ex  - OTP application that starts Bandit on port 4000
  router.ex       - Routes: GET /, GET /greet/:name, 404 catch-all
test/hello_web/
  router_test.exs - Tests for each route
```

## Run it

```bash
chmod +x run.sh && ./run.sh
```

This fetches deps, runs tests, starts the server, curls two endpoints, then stops.
