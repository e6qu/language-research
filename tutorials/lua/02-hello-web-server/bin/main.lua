local server = require("src.server")
local port = arg[1] or "4010"
print("Server module loaded. Run: ./main " .. port)
print("Starting server on port " .. port .. "...")
server.start(tonumber(port))
