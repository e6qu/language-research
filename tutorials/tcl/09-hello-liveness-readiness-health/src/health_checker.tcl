namespace eval health_checker {
    variable deps [dict create]

    proc init {} {
        variable deps
        set deps [dict create database ok cache ok]
    }

    proc set_dependency {name status} {
        variable deps
        dict set deps $name $status
    }

    proc check_all {} {
        variable deps
        return $deps
    }

    proc status {} {
        variable deps
        dict for {name status} $deps {
            if {$status ne "ok"} { return "degraded" }
        }
        return "ok"
    }

    proc liveness_json {} {
        return {{"status":"ok"}}
    }

    proc readiness_json {} {
        set s [status]
        if {$s eq "ok"} {
            return [list {{"status":"ok"}} 200]
        }
        return [list {{"status":"degraded"}} 503]
    }

    proc health_json {} {
        # Build JSON manually
        variable deps
        set checks [list]
        dict for {name status} $deps {
            lappend checks "\"$name\":\{\"status\":\"$status\"\}"
        }
        set checks_json "\{[join $checks ,]\}"
        return "\{\"status\":\"[status]\",\"checks\":$checks_json\}"
    }
}
