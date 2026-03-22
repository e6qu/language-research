local M = {}

function M.make_fetcher(url)
    return coroutine.create(function()
        -- Simulate fetch with coroutine yield
        coroutine.yield("fetching: " .. url)
        return {url = url, status = 200}
    end)
end

function M.fetch_all(urls)
    local coroutines = {}
    for _, url in ipairs(urls) do
        table.insert(coroutines, {co = M.make_fetcher(url), url = url})
    end

    -- Round-robin resume all coroutines
    local results = {}
    local pending = #coroutines
    while pending > 0 do
        for _, entry in ipairs(coroutines) do
            if coroutine.status(entry.co) ~= "dead" then
                local ok, value = coroutine.resume(entry.co)
                if ok and coroutine.status(entry.co) == "dead" then
                    table.insert(results, value)
                    pending = pending - 1
                end
            end
        end
    end
    return results
end

return M
