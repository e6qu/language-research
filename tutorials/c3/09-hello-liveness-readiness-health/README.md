# 09 — Hello Liveness/Readiness/Health (C3)

TCP server exposing Kubernetes-style health probes:

- `GET /livez`   — liveness (is the process alive?)
- `GET /readyz`  — readiness (can it serve traffic?)
- `GET /healthz` — full health with dependency checks

## Prerequisites

C3 is an experimental language. Install `c3c` from <https://c3-lang.org>.

## Usage

```bash
make build
./build/hello-health &
curl http://localhost:3000/livez
curl http://localhost:3000/readyz
```
