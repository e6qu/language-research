local concurrent = require("src.concurrent")

describe("concurrent", function()
    describe("fetch_all", function()
        it("returns empty table for empty input", function()
            local results = concurrent.fetch_all({})
            assert.are.same({}, results)
        end)

        it("returns results for each URL", function()
            local urls = {"http://a.com", "http://b.com", "http://c.com"}
            local results = concurrent.fetch_all(urls)
            assert.are.equal(#urls, #results)
        end)

        it("each result has url and status fields", function()
            local urls = {"http://example.com"}
            local results = concurrent.fetch_all(urls)
            assert.is_not_nil(results[1].url)
            assert.are.equal("http://example.com", results[1].url)
            assert.are.equal(200, results[1].status)
        end)

        it("preserves all URLs in results", function()
            local urls = {"http://a.com", "http://b.com"}
            local results = concurrent.fetch_all(urls)
            local found = {}
            for _, r in ipairs(results) do
                found[r.url] = true
            end
            assert.is_true(found["http://a.com"])
            assert.is_true(found["http://b.com"])
        end)
    end)

    describe("make_fetcher", function()
        it("creates a valid coroutine", function()
            local co = concurrent.make_fetcher("http://test.com")
            assert.are.equal("suspended", coroutine.status(co))
        end)

        it("yields a fetching message on first resume", function()
            local co = concurrent.make_fetcher("http://test.com")
            local ok, msg = coroutine.resume(co)
            assert.is_true(ok)
            assert.are.equal("fetching: http://test.com", msg)
        end)

        it("returns result on second resume", function()
            local co = concurrent.make_fetcher("http://test.com")
            coroutine.resume(co) -- first: yields
            local ok, result = coroutine.resume(co) -- second: returns
            assert.is_true(ok)
            assert.are.equal("http://test.com", result.url)
            assert.are.equal(200, result.status)
        end)
    end)
end)
