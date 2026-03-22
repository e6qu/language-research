package require tcltest
namespace import tcltest::*

source [file join [file dirname [info script]] .. src hello.tcl]

test greet-default "greet with no arg" {
    hello::greet
} "Hello, world!"

test greet-name "greet with name" {
    hello::greet "Alice"
} "Hello, Alice!"

test greet-empty "greet with empty string" {
    hello::greet ""
} "Hello, world!"

cleanupTests
