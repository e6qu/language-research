local M = {}

-- socket is only needed for start(), loaded lazily
local socket

function M.handle_request(request)
    local method, path = request:match("^(%w+)%s+(/[^%s]*)")
    if not method then return 400, '{"error":"bad request"}' end

    if path == "/" then
        return 200, '{"message":"Hello, world!"}'
    end

    local name = path:match("^/greet/(.+)$")
    if name then
        return 200, '{"message":"Hello, ' .. name .. '!"}'
    end

    return 404, '{"error":"not found"}'
end

function M.format_response(status, body)
    local status_text = ({[200]="OK", [400]="Bad Request", [404]="Not Found"})[status] or "Unknown"
    return "HTTP/1.1 " .. status .. " " .. status_text .. "\r\n" ..
           "Content-Type: application/json\r\n" ..
           "Content-Length: " .. #body .. "\r\n" ..
           "Connection: close\r\n\r\n" .. body
end

function M.start(port)
    socket = socket or require("socket")
    local server = assert(socket.bind("127.0.0.1", port))
    print("Listening on port " .. port)
    while true do
        local client = server:accept()
        if client then
            local request = client:receive("*l")
            local status, body = M.handle_request(request or "")
            client:send(M.format_response(status, body))
            client:close()
        end
    end
end

-- CLI entry point (only when run directly, not when required)
if not pcall(debug.getlocal, 4, 1) then
    if arg and arg[0] and arg[0]:find("server%.lua") then
        M.start(tonumber(arg[1]) or 4010)
    end
end

return M
