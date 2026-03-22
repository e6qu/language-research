# 03-hello-cli (Common Lisp)

Command-line argument parser using `sb-ext:*posix-argv*` and `defstruct`.

## Usage

```bash
make test
make fatbin
./hello-cli --name Alice --shout    # => HELLO, ALICE!
./hello-cli Bob                      # => Hello, Bob!
./hello-cli -h                       # => usage info
```

## Notes

- `defstruct` generates constructor, accessors, and copier automatically.
- `sb-ext:*posix-argv*` gives the raw argument list (first element is the program name).
- The condition system could signal a custom `bad-argument` condition with restarts, but simple control flow suffices here.
