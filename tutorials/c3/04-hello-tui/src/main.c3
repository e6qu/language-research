module hello_tui;
import std::io;

fn int main(String[] args) {
    char[] name = "World";
    if (args.len > 1) {
        name = args[1];
    }

    DString greeting = dstring::temp_new();
    greeting.appendf("Hello, %s!", name);
    draw_box("C3 TUI Demo", greeting.str_view());

    io::printn("");
    io::printn("Press Ctrl-C to exit.");

    // Simple input loop — read a line, redraw.
    while (true) {
        io::printf("> ");
        char[256] buf;
        usz! n = io::stdin().read(buf[..]);
        if (catch err = n) break;
        if (n == 0) break;
        char[] input = buf[0..n-1];
        if (input.len > 0 && input[input.len - 1] == '\n') {
            input = input[0..input.len - 2];
        }
        if (input == "quit" || input == "exit") break;
        draw_box("C3 TUI Demo", input);
    }
    return 0;
}
