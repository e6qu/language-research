module hello_tui;
import std::io;

// ANSI escape helpers for terminal UI.
const char[] ESC_CLEAR  = "\x1b[2J\x1b[H";
const char[] ESC_BOLD   = "\x1b[1m";
const char[] ESC_RESET  = "\x1b[0m";
const char[] ESC_GREEN  = "\x1b[32m";
const char[] ESC_CYAN   = "\x1b[36m";
const char[] BOX_TL     = "\u250c";
const char[] BOX_TR     = "\u2510";
const char[] BOX_BL     = "\u2514";
const char[] BOX_BR     = "\u2518";
const char[] BOX_H      = "\u2500";
const char[] BOX_V      = "\u2502";

fn void draw_box(char[] title, char[] body) {
    int width = 40;
    io::printf("%s", ESC_CLEAR);

    // Top border
    io::printf("%s%s", ESC_CYAN, BOX_TL);
    for (int i = 0; i < width; i++) io::printf("%s", BOX_H);
    io::printf("%s%s\n", BOX_TR, ESC_RESET);

    // Title line
    io::printf("%s%s %s%s%s", ESC_CYAN, BOX_V, ESC_BOLD, title, ESC_RESET);
    io::printf("%s%s%s\n", ESC_CYAN, BOX_V, ESC_RESET);

    // Body line
    io::printf("%s%s %s%s%s", ESC_CYAN, BOX_V, ESC_GREEN, body, ESC_RESET);
    io::printf("%s%s%s\n", ESC_CYAN, BOX_V, ESC_RESET);

    // Bottom border
    io::printf("%s%s", ESC_CYAN, BOX_BL);
    for (int i = 0; i < width; i++) io::printf("%s", BOX_H);
    io::printf("%s%s\n", BOX_BR, ESC_RESET);
}
