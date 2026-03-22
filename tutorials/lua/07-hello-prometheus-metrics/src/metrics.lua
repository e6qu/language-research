local M = {}
local counters = {}
local histograms = {}

function M.counter_inc(name, value)
    counters[name] = (counters[name] or 0) + (value or 1)
end

function M.counter_get(name)
    return counters[name] or 0
end

function M.histogram_observe(name, value)
    if not histograms[name] then histograms[name] = {} end
    table.insert(histograms[name], value)
end

function M.format()
    local lines = {}
    for name, value in pairs(counters) do
        table.insert(lines, string.format("# TYPE %s counter", name))
        table.insert(lines, string.format("%s %g", name, value))
    end
    for name, observations in pairs(histograms) do
        local sum = 0
        for _, v in ipairs(observations) do sum = sum + v end
        table.insert(lines, string.format("# TYPE %s histogram", name))
        table.insert(lines, string.format("%s_sum %g", name, sum))
        table.insert(lines, string.format("%s_count %d", name, #observations))
    end
    return table.concat(lines, "\n") .. "\n"
end

function M.reset()
    counters = {}
    histograms = {}
end

return M
