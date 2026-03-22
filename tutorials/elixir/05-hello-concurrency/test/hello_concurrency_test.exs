defmodule HelloConcurrencyTest do
  use ExUnit.Case, async: true

  test "fetch_all with empty list returns []" do
    assert HelloConcurrency.fetch_all([]) == []
  end

  test "fetch/1 with a valid URL returns {:ok, 200}" do
    assert HelloConcurrency.fetch("https://httpbin.org/get") == {:ok, 200}
  end

  test "fetch/1 with invalid URL returns {:error, _}" do
    assert {:error, _reason} = HelloConcurrency.fetch("http://this-host-does-not-exist.invalid/nope")
  end

  test "fetch_all returns results for all URLs" do
    urls = [
      "https://httpbin.org/get",
      "https://httpbin.org/status/404"
    ]

    results = HelloConcurrency.fetch_all(urls)

    assert length(results) == length(urls)

    assert Enum.any?(results, fn {_url, result} -> result == {:ok, 200} end)
    assert Enum.any?(results, fn {_url, result} -> result == {:ok, 404} end)
  end
end
