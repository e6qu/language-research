defmodule HelloOpenapi.RouterTest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn

  @opts HelloOpenapi.Router.init([])

  test "GET /api/openapi returns 200 with openapi key" do
    conn = conn(:get, "/api/openapi")
    conn = HelloOpenapi.Router.call(conn, @opts)

    assert conn.status == 200
    body = Jason.decode!(conn.resp_body)
    assert Map.has_key?(body, "openapi")
  end

  test "GET /api/openapi spec contains /api/greet path" do
    conn = conn(:get, "/api/openapi")
    conn = HelloOpenapi.Router.call(conn, @opts)

    body = Jason.decode!(conn.resp_body)
    paths = body["paths"]
    assert Map.has_key?(paths, "/api/greet")
  end

  test "GET /api/greet?name=Alice returns greeting" do
    conn = conn(:get, "/api/greet?name=Alice")
    conn = HelloOpenapi.Router.call(conn, @opts)

    assert conn.status == 200
    body = Jason.decode!(conn.resp_body)
    assert body["message"] == "Hello, Alice!"
  end

  test "GET /api/greet without name returns 400" do
    conn = conn(:get, "/api/greet")
    conn = HelloOpenapi.Router.call(conn, @opts)

    assert conn.status == 400
  end
end
