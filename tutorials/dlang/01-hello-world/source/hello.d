module hello;

string greet(string name) {
    if (name.length == 0) {
        return "Hello, world!";
    }
    return "Hello, " ~ name ~ "!";
}

unittest {
    assert(greet("") == "Hello, world!");
    assert(greet("Alice") == "Hello, Alice!");
    assert(greet("Bob") == "Hello, Bob!");
}
