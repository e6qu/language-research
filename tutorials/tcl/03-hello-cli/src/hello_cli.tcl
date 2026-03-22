namespace eval hello_cli {
    proc parse_args {argv} {
        set opts [dict create name "world" shout 0]
        set i 0
        while {$i < [llength $argv]} {
            set arg [lindex $argv $i]
            switch -- $arg {
                --name {
                    incr i
                    dict set opts name [lindex $argv $i]
                }
                --shout {
                    dict set opts shout 1
                }
            }
            incr i
        }
        return $opts
    }

    proc format {opts} {
        set msg "Hello, [dict get $opts name]!"
        if {[dict get $opts shout]} {
            set msg [string toupper $msg]
        }
        return $msg
    }
}

if {[info script] eq $::argv0} {
    set opts [hello_cli::parse_args $::argv]
    puts [hello_cli::format $opts]
}
