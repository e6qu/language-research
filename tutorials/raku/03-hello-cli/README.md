# 03-hello-cli

Raku CLI tool showcasing the `MAIN` sub with signature-based argument parsing.

## Usage

```bash
make build   # syntax check
make test    # run tests
make e2e     # end-to-end check
raku bin/hello-cli.raku --name Alice --shout
```

## Structure

- `lib/HelloCli.rakumod` — argument parsing and greeting logic
- `bin/hello-cli.raku` — entry point with MAIN sub
- `t/hello_cli.rakutest` — unit tests
