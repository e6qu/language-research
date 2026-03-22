# 07 — Hello Prometheus Metrics

Parses Prometheus exposition text and renders a live bar chart.

## Quick start

```bash
chmod +x run.sh
./run.sh
```

This compiles the Elm app to `main.js`, then open `index.html` in a browser.

## How it works

- **MetricsParser** strips comment/HELP/TYPE lines and extracts `name value` pairs.
- **BarChart** renders an SVG horizontal bar chart from the parsed metrics.
- **Main** polls `/metrics` every 5 seconds. If the endpoint is unavailable (e.g., Elixir tutorial 07 is not running), sample data is shown as a fallback.

## Tests

```bash
elm-test
```
