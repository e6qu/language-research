local M = {}

function M.greet(name)
    if not name or name == "" then
        return "Hello, world!"
    end
    return "Hello, " .. name .. "!"
end

return M
