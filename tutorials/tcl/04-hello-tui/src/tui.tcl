source [file join [file dirname [info script]] tui_state.tcl]

proc raw_mode {on} {
    if {$on} {
        exec stty raw -echo <@stdin
    } else {
        exec stty -raw echo <@stdin
    }
}

proc clear_screen {} {
    puts -nonewline "\033\[2J\033\[H"
    flush stdout
}

proc main {} {
    set state [tui_state::new]

    raw_mode 1
    fconfigure stdin -buffering none -blocking 1

    while {1} {
        clear_screen
        puts -nonewline "Select a language (j/k to move, Enter to select, q to quit):\n\n"
        puts -nonewline [tui_state::render $state]
        puts -nonewline "\n"
        flush stdout

        set ch [read stdin 1]
        switch -- $ch {
            j { set state [tui_state::move_down $state] }
            k { set state [tui_state::move_up $state] }
            q {
                raw_mode 0
                clear_screen
                puts "Goodbye!"
                return
            }
            "\r" - "\n" {
                raw_mode 0
                clear_screen
                puts "You selected: [tui_state::selected_item $state]"
                return
            }
        }
    }
}

if {[info script] eq $::argv0} {
    main
}
