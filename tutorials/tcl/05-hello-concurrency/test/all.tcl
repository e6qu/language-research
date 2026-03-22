package require tcltest
namespace import tcltest::*

source [file join [file dirname [info script]] .. src concurrent.tcl]

test fetch-empty "fetch_all with empty list returns empty" {
    concurrent::fetch_all {}
} {}

test fetch-single "fetch_all with one URL returns one result" {
    set results [concurrent::fetch_all {http://example.com}]
    llength $results
} 1

test fetch-single-url "single result contains correct url" {
    set results [concurrent::fetch_all {http://example.com}]
    dict get [lindex $results 0] url
} "http://example.com"

test fetch-single-status "single result has status 200" {
    set results [concurrent::fetch_all {http://example.com}]
    dict get [lindex $results 0] status
} 200

test fetch-multiple "fetch_all with multiple URLs returns all results" {
    set urls {http://a.com http://b.com http://c.com}
    set results [concurrent::fetch_all $urls]
    llength $results
} 3

test fetch-multiple-urls "multiple results have correct urls" {
    set urls {http://a.com http://b.com}
    set results [concurrent::fetch_all $urls]
    list [dict get [lindex $results 0] url] [dict get [lindex $results 1] url]
} {http://a.com http://b.com}

test make-fetcher "make_fetcher creates a coroutine" {
    set coro [concurrent::make_fetcher "http://test.com"]
    set exists [expr {[info commands $coro] ne ""}]
    # Drive the coroutine to completion
    $coro
    set exists
} 1

cleanupTests
