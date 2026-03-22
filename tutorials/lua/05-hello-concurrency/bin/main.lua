local concurrent = require("src.concurrent")
local urls = {"http://example.com/a", "http://example.com/b"}
local results = concurrent.fetch_all(urls)
for _, r in ipairs(results) do
    print(r.url .. " -> " .. tostring(r.status))
end
