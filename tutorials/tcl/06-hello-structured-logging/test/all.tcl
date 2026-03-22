package require tcltest
namespace import ::tcltest::*

source [file join [file dirname [info script]] .. src logger.tcl]

test json-valid-braces "log returns valid JSON with braces and required keys" -body {
    set result [logger::info "hello"]
    set has_open [string match "*\{*" $result]
    set has_close [string match "*\}*" $result]
    set has_message [string match "*\"message\"*" $result]
    set has_level [string match "*\"level\"*" $result]
    set has_timestamp [string match "*\"timestamp\"*" $result]
    list $has_open $has_close $has_message $has_level $has_timestamp
} -result {1 1 1 1 1}

test output-has-message-key "output has message key with correct value" -body {
    set result [logger::info "test message"]
    string match "*\"message\":\"test message\"*" $result
} -result 1

test output-has-level-key "output has level key" -body {
    set result [logger::warn "warning"]
    string match "*\"level\":\"warn\"*" $result
} -result 1

test metadata-included "metadata is included in output" -body {
    set result [logger::info "hello" service "myapp" version "1.0"]
    set has_service [string match "*\"service\":\"myapp\"*" $result]
    set has_version [string match "*\"version\":\"1.0\"*" $result]
    list $has_service $has_version
} -result {1 1}

test info-sets-level "info sets level to info" -body {
    set result [logger::info "msg"]
    string match "*\"level\":\"info\"*" $result
} -result 1

test error-sets-level "error sets level to error" -body {
    set result [logger::error "msg"]
    string match "*\"level\":\"error\"*" $result
} -result 1

cleanupTests
