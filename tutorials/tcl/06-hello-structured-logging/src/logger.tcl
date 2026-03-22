namespace eval logger {
    proc json_encode {dict} {
        set pairs [list]
        dict for {key value} $dict {
            if {[string is integer -strict $value] || [string is double -strict $value]} {
                lappend pairs "\"$key\":$value"
            } else {
                # Escape special JSON chars
                set escaped [string map {\" \\\" \\ \\\\ \n \\n \t \\t} $value]
                lappend pairs "\"$key\":\"$escaped\""
            }
        }
        return "\{[join $pairs ,]\}"
    }

    proc log {level message args} {
        set entry [dict create \
            level $level \
            message $message \
            timestamp [clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%SZ" -gmt 1]]

        # Add metadata
        foreach {key value} $args {
            dict set entry $key $value
        }
        return [json_encode $entry]
    }

    proc info {message args} { return [log "info" $message {*}$args] }
    proc warn {message args} { return [log "warn" $message {*}$args] }
    proc error {message args} { return [log "error" $message {*}$args] }
}
