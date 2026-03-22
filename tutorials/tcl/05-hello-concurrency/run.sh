#!/usr/bin/env bash
set -euo pipefail

tclsh << 'EOF'
source src/concurrent.tcl

set urls {http://example.com/api http://example.com/data http://example.com/status}

puts "Fetching [llength $urls] URLs with coroutines..."
set results [concurrent::fetch_all $urls]

foreach result $results {
    puts "  [dict get $result url] -> status [dict get $result status]"
}
puts "Done. Fetched [llength $results] results."
EOF
