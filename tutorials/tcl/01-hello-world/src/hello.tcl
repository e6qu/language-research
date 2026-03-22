namespace eval hello {
    proc greet {{name ""}} {
        if {$name eq ""} {
            return "Hello, world!"
        }
        return "Hello, $name!"
    }
}
