namespace eval openapi_spec {

    proc spec {} {
        return [dict create \
            openapi "3.0.0" \
            info [dict create title "Hello API" version "1.0.0"] \
            paths [dict create "/api/greet" "GET"]]
    }

    proc spec_json {} {
        # Hand-build JSON to avoid Tcl dict/list/string ambiguity in recursive encoding
        set s [spec]
        set openapi [dict get $s openapi]
        set title [dict get [dict get $s info] title]
        set version [dict get [dict get $s info] version]
        set paths_key [lindex [dict keys [dict get $s paths]] 0]
        set paths_val [dict get [dict get $s paths] $paths_key]
        return "\{\"openapi\":\"$openapi\",\"info\":\{\"title\":\"$title\",\"version\":\"$version\"\},\"paths\":\{\"$paths_key\":\"$paths_val\"\}\}"
    }

    proc validate_name {name} {
        if {$name eq ""} {
            return [list 0 "name parameter is required"]
        }
        return [list 1 $name]
    }
}
