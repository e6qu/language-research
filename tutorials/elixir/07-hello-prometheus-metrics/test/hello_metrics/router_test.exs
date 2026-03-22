defmodule HelloMetrics.RouterTest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn

  @opts HelloMetrics.Router.init([])

  test "GET /metrics returns 200" do
    conn = conn(:get, "/metrics") |> HelloMetrics.Router.call(@opts)
    assert conn.status == 200
  end

  test "GET /work returns 200" do
    conn = conn(:get, "/work") |> HelloMetrics.Router.call(@opts)
    assert conn.status == 200
  end

  test "GET /metrics contains hello_work after hitting /work" do
    _work = conn(:get, "/work") |> HelloMetrics.Router.call(@opts)

    # Give telemetry a moment to process
    Process.sleep(100)

    conn = conn(:get, "/metrics") |> HelloMetrics.Router.call(@opts)
    assert conn.resp_body =~ "hello_work"
  end
end
