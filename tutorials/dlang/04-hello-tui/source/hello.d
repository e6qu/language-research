module hello;

import std.format : format;

enum Color : string {
    reset  = "\033[0m",
    red    = "\033[31m",
    green  = "\033[32m",
    yellow = "\033[33m",
    blue   = "\033[34m",
    cyan   = "\033[36m",
    bold   = "\033[1m",
}

struct TuiState {
    string title;
    string[] items;
    int selected;
    string statusMessage;
}

TuiState initState() {
    return TuiState(
        "Hello TUI",
        ["Greet World", "Greet Alice", "Greet Bob", "Quit"],
        0,
        "Use j/k to navigate, Enter to select, q to quit"
    );
}

TuiState moveDown(TuiState state) {
    if (state.selected < cast(int) state.items.length - 1) {
        state.selected++;
    }
    return state;
}

TuiState moveUp(TuiState state) {
    if (state.selected > 0) {
        state.selected--;
    }
    return state;
}

TuiState selectItem(TuiState state) {
    if (state.selected == cast(int) state.items.length - 1) {
        state.statusMessage = "Goodbye!";
    } else {
        string[] names = ["world", "Alice", "Bob"];
        state.statusMessage = format!"Hello, %s!"(names[state.selected]);
    }
    return state;
}

string render(TuiState state) {
    string output;
    output ~= "\033[2J\033[H"; // clear screen, cursor home
    output ~= Color.bold ~ Color.cyan ~ "=== " ~ state.title ~ " ===" ~ Color.reset ~ "\n\n";

    foreach (i, item; state.items) {
        if (i == state.selected) {
            output ~= Color.green ~ " > " ~ item ~ Color.reset ~ "\n";
        } else {
            output ~= "   " ~ item ~ "\n";
        }
    }

    output ~= "\n" ~ Color.yellow ~ state.statusMessage ~ Color.reset ~ "\n";
    return output;
}

unittest {
    auto s = initState();
    assert(s.selected == 0);
    assert(s.items.length == 4);

    auto s2 = moveDown(s);
    assert(s2.selected == 1);

    auto s3 = moveDown(moveDown(moveDown(s)));
    assert(s3.selected == 3);
    auto s4 = moveDown(s3); // should not go past end
    assert(s4.selected == 3);

    auto s5 = moveUp(s);
    assert(s5.selected == 0); // should not go below 0

    auto s6 = selectItem(s);
    assert(s6.statusMessage == "Hello, world!");

    auto s7 = selectItem(moveDown(s));
    assert(s7.statusMessage == "Hello, Alice!");

    auto rendered = render(s);
    assert(rendered.length > 0);
}
