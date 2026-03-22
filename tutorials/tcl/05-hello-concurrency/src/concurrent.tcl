namespace eval concurrent {
    proc make_fetcher {url} {
        set name "fetcher_[clock microseconds]_[expr {int(rand()*10000)}]"
        coroutine $name apply {{url} {
            yield "fetching"
            return [dict create url $url status 200]
        }} $url
        return $name
    }

    proc fetch_all {urls} {
        set coros [list]
        foreach url $urls {
            lappend coros [make_fetcher $url]
        }

        set results [list]
        foreach coro $coros {
            while {[info commands $coro] ne ""} {
                set result [$coro]
                if {[info commands $coro] eq ""} {
                    lappend results $result
                }
            }
        }
        return $results
    }
}
