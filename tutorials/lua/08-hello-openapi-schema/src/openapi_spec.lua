local json = require("dkjson")

local M = {}

function M.spec()
    return {
        openapi = "3.0.0",
        info = {title = "Hello API", version = "1.0.0"},
        paths = {
            ["/api/greet"] = {
                get = {
                    summary = "Get a greeting",
                    parameters = {{
                        name = "name", ["in"] = "query",
                        required = true,
                        schema = {type = "string"}
                    }},
                    responses = {
                        ["200"] = {
                            description = "A greeting",
                            content = {["application/json"] = {
                                schema = {type = "object", properties = {
                                    message = {type = "string"}
                                }}
                            }}
                        }
                    }
                }
            }
        }
    }
end

function M.to_json()
    return json.encode(M.spec(), {indent = true})
end

function M.validate_name(name)
    if not name or name == "" then
        return nil, "name parameter is required"
    end
    return name
end

return M
