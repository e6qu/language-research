import hello;
import std.stdio;
import core.stdc.stdio : fgetc, stdin;
import core.sys.posix.termios;
import core.sys.posix.unistd : STDIN_FILENO;

void enableRawMode(ref termios orig) {
    tcgetattr(STDIN_FILENO, &orig);
    auto raw = orig;
    raw.c_lflag &= ~(ICANON | ECHO);
    raw.c_cc[VMIN] = 1;
    raw.c_cc[VTIME] = 0;
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
}

void disableRawMode(ref termios orig) {
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig);
}

void main() {
    termios orig;
    enableRawMode(orig);
    scope(exit) {
        disableRawMode(orig);
        write("\033[2J\033[H"); // clear on exit
    }

    auto state = initState();
    write(render(state));

    while (true) {
        auto ch = fgetc(stdin);
        if (ch == 'q') {
            break;
        } else if (ch == 'j') {
            state = moveDown(state);
        } else if (ch == 'k') {
            state = moveUp(state);
        } else if (ch == '\n' || ch == '\r') {
            state = selectItem(state);
            if (state.statusMessage == "Goodbye!") {
                write(render(state));
                break;
            }
        }
        write(render(state));
    }
}
