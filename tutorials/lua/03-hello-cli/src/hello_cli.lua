local function parse_args(args)
    local opts = {name = "world", shout = false}
    local i = 1
    while i <= #args do
        if args[i] == "--name" and args[i+1] then
            opts.name = args[i+1]
            i = i + 2
        elseif args[i] == "--shout" then
            opts.shout = true
            i = i + 1
        else
            i = i + 1
        end
    end
    return opts
end

local function format(opts)
    local msg = "Hello, " .. opts.name .. "!"
    if opts.shout then msg = msg:upper() end
    return msg
end

-- Module exports for testing
local M = {parse_args = parse_args, format = format}

-- CLI entry point
if arg then
    local opts = parse_args(arg)
    print(format(opts))
end

return M
