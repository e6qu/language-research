package require tcltest
namespace import tcltest::*

source [file join [file dirname [info script]] .. src server.tcl]

test handle-root "GET / returns 200 and hello world" {
    lassign [server::handle_request "GET / HTTP/1.1"] status body
    list $status $body
} {200 {"message":"Hello, world!"}}

test handle-greet "GET /greet/Alice returns 200 and greeting" {
    lassign [server::handle_request "GET /greet/Alice HTTP/1.1"] status body
    list $status $body
} {200 {"message":"Hello, Alice!"}}

test handle-not-found "GET /unknown returns 404" {
    lassign [server::handle_request "GET /unknown HTTP/1.1"] status body
    list $status
} {404}

test format-response-200 "format_response builds HTTP response" {
    set resp [server::format_response 200 {{"ok":true}}]
    string match "HTTP/1.1 200 OK*" $resp
} 1

cleanupTests
