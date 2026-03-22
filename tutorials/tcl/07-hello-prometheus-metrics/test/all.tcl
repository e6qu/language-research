package require tcltest
namespace import ::tcltest::*

source [file join [file dirname [info script]] .. src metrics.tcl]

test counter-inc-and-get "counter_inc and counter_get work" -setup {
    metrics::reset
} -body {
    metrics::counter_inc http_requests
    metrics::counter_inc http_requests
    metrics::counter_inc http_requests 3
    metrics::counter_get http_requests
} -result 5

test counter-get-unknown "counter_get unknown returns 0" -setup {
    metrics::reset
} -body {
    metrics::counter_get nonexistent_counter
} -result 0

test format-contains-counter "format contains counter name" -setup {
    metrics::reset
} -body {
    metrics::counter_inc http_requests 10
    set output [metrics::format]
    set has_type [string match "*# TYPE http_requests counter*" $output]
    set has_value [string match "*http_requests 10*" $output]
    list $has_type $has_value
} -result {1 1}

test histogram-format "histogram_observe + format contains sum and count" -setup {
    metrics::reset
} -body {
    metrics::histogram_observe request_duration 0.5
    metrics::histogram_observe request_duration 1.5
    metrics::histogram_observe request_duration 2.0
    set output [metrics::format]
    set has_type [string match "*# TYPE request_duration histogram*" $output]
    set has_sum [string match "*request_duration_sum 4.0*" $output]
    set has_count [string match "*request_duration_count 3*" $output]
    list $has_type $has_sum $has_count
} -result {1 1 1}

test reset-clears "reset clears metrics" -setup {
    metrics::reset
} -body {
    metrics::counter_inc http_requests 5
    metrics::histogram_observe latency 1.0
    metrics::reset
    set counter_val [metrics::counter_get http_requests]
    set output [metrics::format]
    list $counter_val $output
} -result {0 {}}

cleanupTests
