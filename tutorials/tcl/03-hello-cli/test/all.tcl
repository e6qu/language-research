package require tcltest
namespace import tcltest::*

source [file join [file dirname [info script]] .. src hello_cli.tcl]

test parse-defaults "parse_args with no args uses defaults" {
    set opts [hello_cli::parse_args {}]
    list [dict get $opts name] [dict get $opts shout]
} {world 0}

test parse-name "parse_args with --name" {
    set opts [hello_cli::parse_args {--name Alice}]
    dict get $opts name
} "Alice"

test parse-shout "parse_args with --shout" {
    set opts [hello_cli::parse_args {--shout}]
    dict get $opts shout
} 1

test parse-combined "parse_args with --name and --shout" {
    set opts [hello_cli::parse_args {--name Bob --shout}]
    list [dict get $opts name] [dict get $opts shout]
} {Bob 1}

test format-normal "format without shout" {
    hello_cli::format [dict create name "Alice" shout 0]
} "Hello, Alice!"

test format-shout "format with shout" {
    hello_cli::format [dict create name "Alice" shout 1]
} "HELLO, ALICE!"

test format-default "format with default name" {
    hello_cli::format [dict create name "world" shout 0]
} "Hello, world!"

cleanupTests
