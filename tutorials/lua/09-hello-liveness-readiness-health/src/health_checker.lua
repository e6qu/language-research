local json = require("dkjson")

local M = {}
local deps = {}

function M.init()
    deps = {database = "ok", cache = "ok"}
end

function M.set_dependency(name, status)
    deps[name] = status
end

function M.check_all()
    local copy = {}
    for k, v in pairs(deps) do copy[k] = v end
    return copy
end

function M.status()
    for _, v in pairs(deps) do
        if v ~= "ok" then return "degraded" end
    end
    return "ok"
end

function M.liveness_json()
    return json.encode({status = "ok"})
end

function M.readiness_json()
    local s = M.status()
    return json.encode({status = s}), s == "ok" and 200 or 503
end

function M.health_json()
    local checks = {}
    for name, status in pairs(deps) do
        checks[name] = {status = status}
    end
    return json.encode({status = M.status(), checks = checks})
end

return M
