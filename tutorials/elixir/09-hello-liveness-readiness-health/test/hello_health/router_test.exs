defmodule HelloHealth.RouterTest do
  use ExUnit.Case, async: false
  import Plug.Test
  import Plug.Conn

  setup do
    HelloHealth.Checker.set_dependency(:database, :ok)
    HelloHealth.Checker.set_dependency(:cache, :ok)
    :ok
  end

  test "GET /healthz returns 200" do
    conn = conn(:get, "/healthz") |> HelloHealth.Router.call([])
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"status" => "ok"}
  end

  test "GET /readyz returns 200 when all ok" do
    conn = conn(:get, "/readyz") |> HelloHealth.Router.call([])
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"status" => "ok"}
  end

  test "GET /readyz returns 503 when degraded" do
    HelloHealth.Checker.set_dependency(:database, :error)
    conn = conn(:get, "/readyz") |> HelloHealth.Router.call([])
    assert conn.status == 503
  end

  test "GET /health returns 200 with checks object" do
    conn = conn(:get, "/health") |> HelloHealth.Router.call([])
    assert conn.status == 200
    body = Jason.decode!(conn.resp_body)
    assert body["status"] == "ok"
    assert body["checks"]["database"]["status"] == "ok"
    assert body["checks"]["cache"]["status"] == "ok"
  end
end
