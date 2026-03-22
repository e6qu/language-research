#!/usr/bin/env bash
# Cross-language consistency test — 9 tutorials × 19 languages = 171 checks
#
# This is a BLACKBOX test. For each tutorial, the same `make e2e` target is
# run across all 19 language implementations. The e2e target exercises the
# built artifact (binary, server, script) through its external interface:
#
#   01: run binary, check output contains "Hello"
#   02: start HTTP server, curl endpoints, check JSON responses
#   03: run CLI with --name/--shout flags, check output
#   04: verify TUI builds (interactive, cannot blackbox test runtime)
#   05: run concurrency demo, check output
#   06: run logger, verify JSON output
#   07: check /metrics endpoint or metrics output
#   08: check OpenAPI spec output
#   09: check /healthz /readyz /health endpoints
#
# Every implementation must pass the SAME e2e test to prove behavioral equivalence.
#
# Prerequisites: run `make build` first.
# Usage: ./test-consistency.sh [tutorial_number]

set -euo pipefail
cd "$(dirname "$0")"

PASS=0
FAIL=0

TUTORIALS=(
    "01-hello-world"
    "02-hello-web-server"
    "03-hello-cli"
    "04-hello-tui"
    "05-hello-concurrency"
    "06-hello-structured-logging"
    "07-hello-prometheus-metrics"
    "08-hello-openapi-schema"
    "09-hello-liveness-readiness-health"
)

LANGS=(elixir erlang elm lua tcl perl raku rust rust-wasm golang java java-springboot java-quarkus clojure zig dlang c3 scheme common-lisp)

run_tutorial() {
    local tutorial="$1"
    echo "=== $tutorial ==="
    for lang in "${LANGS[@]}"; do
        local d="$lang/$tutorial"
        [ -d "$d" ] || continue
        printf "  %-20s %-40s " "$lang" "$tutorial"
        if timeout 120 make -C "$d" e2e > /tmp/consistency-${lang}-${tutorial}.log 2>&1; then
            echo "PASS"
            PASS=$((PASS + 1))
        else
            echo "FAIL"
            FAIL=$((FAIL + 1))
            tail -3 /tmp/consistency-${lang}-${tutorial}.log | sed 's/^/    /'
        fi
    done
}

# ─── Run selected or all ──────────────────────────────────────
FILTER="${1:-all}"

for t in "${TUTORIALS[@]}"; do
    num="${t%%-*}"
    if [ "$FILTER" = "all" ] || [ "$FILTER" = "$num" ]; then
        run_tutorial "$t"
    fi
done

echo ""
echo "=== Consistency Results ==="
echo "  Passed:  $PASS"
echo "  Failed:  $FAIL"
echo "  Total:   $((PASS + FAIL))"

if [ "$FAIL" -gt 0 ]; then
    echo ""
    echo "Failed tests:"
    for t in "${TUTORIALS[@]}"; do
        for lang in "${LANGS[@]}"; do
            log="/tmp/consistency-${lang}-${t}.log"
            [ -f "$log" ] && ! grep -q "E2E: PASS\|e2e passed\|E2E PASSED" "$log" 2>/dev/null && echo "  $lang/$t"
        done
    done
    exit 1
fi
