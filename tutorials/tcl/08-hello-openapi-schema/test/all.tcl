package require tcltest
namespace import ::tcltest::*

source [file join [file dirname [info script]] .. src openapi_spec.tcl]

test spec-has-openapi-key "spec has openapi key" -body {
    set s [openapi_spec::spec]
    dict get $s openapi
} -result "3.0.0"

test spec-has-paths "spec has paths with /api/greet" -body {
    set s [openapi_spec::spec]
    set paths [dict get $s paths]
    dict exists $paths "/api/greet"
} -result 1

test spec-json-contains-openapi "spec_json returns string containing openapi" -body {
    set json [openapi_spec::spec_json]
    string match "*openapi*" $json
} -result 1

test validate-name-valid "validate_name with valid returns 1 + name" -body {
    openapi_spec::validate_name "Alice"
} -result {1 Alice}

test validate-name-empty "validate_name with empty returns 0 + error" -body {
    openapi_spec::validate_name ""
} -result {0 {name parameter is required}}

cleanupTests
