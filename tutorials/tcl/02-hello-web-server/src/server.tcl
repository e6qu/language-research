namespace eval server {
    proc handle_request {request} {
        set parts [split $request " "]
        set method [lindex $parts 0]
        set path [lindex $parts 1]

        if {$path eq "/"} {
            return [list 200 {{"message":"Hello, world!"}}]
        }

        if {[regexp {^/greet/(.+)$} $path -> name]} {
            return [list 200 "{\"message\":\"Hello, $name!\"}"]
        }

        return [list 404 {{"error":"not found"}}]
    }

    proc format_response {status body} {
        set status_text [dict get {200 OK 400 {Bad Request} 404 {Not Found}} $status]
        set len [string length $body]
        return "HTTP/1.1 $status $status_text\r\nContent-Type: application/json\r\nContent-Length: $len\r\nConnection: close\r\n\r\n$body"
    }

    proc accept {sock addr port} {
        gets $sock request
        lassign [handle_request $request] status body
        puts -nonewline $sock [format_response $status $body]
        close $sock
    }

    proc start {port} {
        set srv [socket -server [namespace code accept] $port]
        puts "Listening on port $port"
        vwait forever
    }
}

if {[info script] eq $::argv0} {
    set port 8080
    if {[llength $::argv] > 0} {
        set port [lindex $::argv 0]
    }
    server::start $port
}
