package require tcltest
namespace import ::tcltest::*

source [file join [file dirname [info script]] .. src health_checker.tcl]

test init-sets-deps "init sets deps" -body {
    health_checker::init
    set deps [health_checker::check_all]
    set has_db [dict exists $deps database]
    set has_cache [dict exists $deps cache]
    list $has_db $has_cache
} -result {1 1}

test status-ok-initially "status returns ok initially" -body {
    health_checker::init
    health_checker::status
} -result "ok"

test status-degraded "after set_dependency database error, status is degraded" -body {
    health_checker::init
    health_checker::set_dependency database "error"
    health_checker::status
} -result "degraded"

test check-all-returns-dict "check_all returns dict" -body {
    health_checker::init
    set deps [health_checker::check_all]
    dict get $deps database
} -result "ok"

test liveness-json-has-ok "liveness_json has status ok" -body {
    string match "*\"status\":\"ok\"*" [health_checker::liveness_json]
} -result 1

test readiness-503-when-degraded "readiness_json returns 503 when degraded" -body {
    health_checker::init
    health_checker::set_dependency cache "error"
    set result [health_checker::readiness_json]
    lindex $result 1
} -result 503

cleanupTests
