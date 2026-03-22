namespace eval metrics {
    variable counters [dict create]
    variable histograms [dict create]

    proc counter_inc {name {value 1}} {
        variable counters
        set current [expr {[dict exists $counters $name] ? [dict get $counters $name] : 0}]
        dict set counters $name [expr {$current + $value}]
    }

    proc counter_get {name} {
        variable counters
        if {[dict exists $counters $name]} {
            return [dict get $counters $name]
        }
        return 0
    }

    proc histogram_observe {name value} {
        variable histograms
        if {![dict exists $histograms $name]} {
            dict set histograms $name [list]
        }
        dict lappend histograms $name $value
    }

    proc format {} {
        variable counters
        variable histograms
        set lines [list]
        dict for {name value} $counters {
            lappend lines "# TYPE $name counter"
            lappend lines "$name $value"
        }
        dict for {name observations} $histograms {
            set sum 0
            foreach v $observations { set sum [expr {$sum + $v}] }
            lappend lines "# TYPE $name histogram"
            lappend lines "${name}_sum $sum"
            lappend lines "${name}_count [llength $observations]"
        }
        return [join $lines "\n"]
    }

    proc reset {} {
        variable counters [dict create]
        variable histograms [dict create]
    }
}
