package require tcltest
namespace import tcltest::*

source [file join [file dirname [info script]] .. src tui_state.tcl]

test new-state "new creates state with default items and cursor 0" {
    set s [tui_state::new]
    list [llength [dict get $s items]] [dict get $s cursor]
} {5 0}

test new-custom "new with custom items" {
    set s [tui_state::new {A B C}]
    dict get $s items
} {A B C}

test selected-initial "selected_item returns first item initially" {
    set s [tui_state::new]
    tui_state::selected_item $s
} "Tcl"

test move-down "move_down increments cursor" {
    set s [tui_state::new]
    set s [tui_state::move_down $s]
    dict get $s cursor
} 1

test move-down-selected "move_down changes selected item" {
    set s [tui_state::new]
    set s [tui_state::move_down $s]
    tui_state::selected_item $s
} "Lua"

test move-up "move_up decrements cursor" {
    set s [tui_state::new]
    set s [tui_state::move_down $s]
    set s [tui_state::move_down $s]
    set s [tui_state::move_up $s]
    dict get $s cursor
} 1

test move-up-at-top "move_up at top stays at 0" {
    set s [tui_state::new]
    set s [tui_state::move_up $s]
    dict get $s cursor
} 0

test move-down-at-bottom "move_down at bottom stays at last" {
    set s [tui_state::new {A B}]
    set s [tui_state::move_down $s]
    set s [tui_state::move_down $s]
    set s [tui_state::move_down $s]
    dict get $s cursor
} 1

test selected-after-moves "selected_item after multiple moves" {
    set s [tui_state::new]
    set s [tui_state::move_down $s]
    set s [tui_state::move_down $s]
    set s [tui_state::move_down $s]
    tui_state::selected_item $s
} "Erlang"

cleanupTests
