namespace eval tui_state {
    variable default_items [list Tcl Lua Elixir Erlang Elm]

    proc new {{items {}}} {
        variable default_items
        if {[llength $items] == 0} {
            set items $default_items
        }
        return [dict create items $items cursor 0]
    }

    proc move_down {state} {
        set cursor [dict get $state cursor]
        set items [dict get $state items]
        if {$cursor < [expr {[llength $items] - 1}]} {
            dict set state cursor [expr {$cursor + 1}]
        }
        return $state
    }

    proc move_up {state} {
        set cursor [dict get $state cursor]
        if {$cursor > 0} {
            dict set state cursor [expr {$cursor - 1}]
        }
        return $state
    }

    proc selected_item {state} {
        return [lindex [dict get $state items] [dict get $state cursor]]
    }

    proc render {state} {
        set items [dict get $state items]
        set cursor [dict get $state cursor]
        set lines [list]
        set i 0
        foreach item $items {
            if {$i == $cursor} {
                lappend lines "\033\[7m> $item\033\[0m"
            } else {
                lappend lines "  $item"
            }
            incr i
        }
        return [join $lines "\n"]
    }
}
