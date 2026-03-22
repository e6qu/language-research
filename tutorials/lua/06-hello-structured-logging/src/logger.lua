local json = require("dkjson")

local M = {}

function M.log(level, message, metadata)
    local entry = {
        level = level,
        message = message,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    if metadata then
        for k, v in pairs(metadata) do
            entry[k] = v
        end
    end
    return json.encode(entry)
end

function M.info(message, metadata)  return M.log("info", message, metadata) end
function M.warn(message, metadata)  return M.log("warn", message, metadata) end
function M.error(message, metadata) return M.log("error", message, metadata) end

return M
