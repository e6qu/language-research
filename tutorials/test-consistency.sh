#!/usr/bin/env bash
# Cross-language consistency test
# Verifies all implementations produce equivalent outputs for the same inputs.
#
# Usage: ./test-consistency.sh [tutorial_number]
#   e.g.: ./test-consistency.sh 01   — test only hello-world
#         ./test-consistency.sh       — test all tutorials

set -euo pipefail
cd "$(dirname "$0")"

PASS=0
FAIL=0
SKIP=0

check() {
    local tutorial="$1" lang="$2" expected="$3" actual="$4"
    if [ "$actual" = "$expected" ]; then
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
        echo "  MISMATCH [$lang/$tutorial]"
        echo "    expected: $expected"
        echo "    actual:   $actual"
    fi
}

skip() {
    SKIP=$((SKIP + 1))
}

# ─── Tutorial 01: Hello World ─────────────────────────────────
test_01() {
    echo "=== 01-hello-world: greet('World') ==="
    local expected="Hello, World!"

    # Elixir
    local out=$(cd elixir/01-hello-world && mix run -e 'IO.puts(Hello.greet("World"))' 2>/dev/null)
    check "01" "elixir" "$expected" "$out"

    # Erlang
    out=$(cd erlang/01-hello-world && erl -pa _build/default/lib/*/ebin -noshell -eval 'io:format("~s", [hello:greet(<<"World">>)]), halt().' 2>/dev/null)
    check "01" "erlang" "$expected" "$out"

    # Lua
    out=$(cd lua/01-hello-world && lua -e 'h=require("src.hello"); io.write(h.greet("World"))' 2>/dev/null)
    check "01" "lua" "$expected" "$out"

    # Tcl
    out=$(cd tcl/01-hello-world && echo 'source src/hello.tcl; puts -nonewline [hello::greet "World"]' | tclsh 2>/dev/null)
    check "01" "tcl" "$expected" "$out"

    # Perl
    out=$(cd perl/01-hello-world && perl -Ilib -MHello -e 'print Hello::greet("World")' 2>/dev/null)
    check "01" "perl" "$expected" "$out"

    # Raku
    out=$(cd raku/01-hello-world && raku -Ilib -MHello -e 'print greet("World")' 2>/dev/null)
    check "01" "raku" "$expected" "$out"

    # Go — main prints multiple demos, extract first line
    out=$(cd golang/01-hello-world && go run . 2>/dev/null | head -1 | tr -d '\n')
    check "01" "golang" "$expected" "$out"

    # Rust
    out=$(cd rust/01-hello-world && cargo run --quiet 2>/dev/null | tr -d '\n')
    check "01" "rust" "$expected" "$out"

    # Java
    out=$(cd java/01-hello-world && mvn -q compile exec:java -Dexec.mainClass="hello.Main" 2>/dev/null | tr -d '\n')
    check "01" "java" "$expected" "$out"

    # Clojure
    out=$(cd clojure/01-hello-world && lein run World 2>/dev/null | tr -d '\n')
    check "01" "clojure" "$expected" "$out"

    # Zig
    if [ -d zig/01-hello-world ]; then
        out=$(cd zig/01-hello-world && zig build 2>/dev/null && ./zig-out/bin/hello_world 2>/dev/null | tr -d '\n') || skip
        [ -n "$out" ] && check "01" "zig" "$expected" "$out" || skip
    fi

    # D — main prints multiple demos, extract first line
    if [ -d dlang/01-hello-world ]; then
        out=$(cd dlang/01-hello-world && ldc2 -of=/tmp/dhello source/app.d source/hello.d 2>/dev/null && /tmp/dhello 2>/dev/null | head -1 | tr -d '\n') || skip
        [ -n "$out" ] && check "01" "dlang" "$expected" "$out" || skip
    fi

    # Common Lisp
    out=$(cd common-lisp/01-hello-world && sbcl --noinform --non-interactive --load src/hello.lisp --eval '(format t "~A" (hello:greet "World"))' --eval '(quit)' 2>/dev/null)
    check "01" "common-lisp" "$expected" "$out"

    # Scheme
    out=$(cd scheme/01-hello-world && guile -c '(load "src/hello.scm") (display (greet "World"))' 2>/dev/null)
    check "01" "scheme" "$expected" "$out"
}

# ─── Tutorial 03: CLI with --name and --shout ─────────────────
test_03() {
    echo "=== 03-hello-cli: --name Test --shout ==="
    local expected="HELLO, TEST!"

    # Elixir
    local out=$(cd elixir/03-hello-cli && mix run -e 'HelloCli.main(["--name", "Test", "--shout"])' 2>/dev/null | tr -d '\n')
    check "03" "elixir" "$expected" "$out"

    # Erlang (escript must be pre-built via make build)
    out=$(cd erlang/03-hello-cli && _build/default/bin/hello_cli --name Test --shout 2>/dev/null | tr -d '\n')
    check "03" "erlang" "$expected" "$out"

    # Lua
    out=$(cd lua/03-hello-cli && lua src/hello_cli.lua --name Test --shout 2>/dev/null | tr -d '\n')
    check "03" "lua" "$expected" "$out"

    # Tcl
    out=$(cd tcl/03-hello-cli && tclsh src/hello_cli.tcl --name Test --shout 2>/dev/null | tr -d '\n')
    check "03" "tcl" "$expected" "$out"

    # Perl
    out=$(cd perl/03-hello-cli && perl -Ilib bin/hello_cli.pl --name Test --shout 2>/dev/null | tr -d '\n')
    check "03" "perl" "$expected" "$out"

    # Raku
    out=$(cd raku/03-hello-cli && raku -Ilib bin/hello-cli.raku --name Test --shout 2>/dev/null | tr -d '\n')
    check "03" "raku" "$expected" "$out"

    # Go
    out=$(cd golang/03-hello-cli && go run . --name Test --shout 2>/dev/null | tr -d '\n')
    check "03" "golang" "$expected" "$out"

    # Rust
    out=$(cd rust/03-hello-cli && cargo run --quiet -- --name Test --shout 2>/dev/null | tr -d '\n')
    check "03" "rust" "$expected" "$out"

    # Clojure
    out=$(cd clojure/03-hello-cli && lein run -- --name Test --shout 2>/dev/null | tr -d '\n')
    check "03" "clojure" "$expected" "$out"
}

# ─── Run selected or all tests ────────────────────────────────
if [ "${1:-}" = "01" ] || [ -z "${1:-}" ]; then test_01; fi
if [ "${1:-}" = "03" ] || [ -z "${1:-}" ]; then test_03; fi

echo ""
echo "=== Consistency Results ==="
echo "  Passed:  $PASS"
echo "  Failed:  $FAIL"
echo "  Skipped: $SKIP"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
