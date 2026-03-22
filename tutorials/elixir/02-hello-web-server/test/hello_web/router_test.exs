defmodule HelloWeb.RouterTest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn

  @opts HelloWeb.Router.init([])

  test "GET / returns 200 with hello world JSON" do
    conn = conn(:get, "/") |> HelloWeb.Router.call(@opts)

    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"message" => "Hello, world!"}
  end

  test "GET /greet/:name returns 200 with personalized greeting" do
    conn = conn(:get, "/greet/Alice") |> HelloWeb.Router.call(@opts)

    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"message" => "Hello, Alice!"}
  end

  test "GET unknown route returns 404" do
    conn = conn(:get, "/nope") |> HelloWeb.Router.call(@opts)

    assert conn.status == 404
    assert Jason.decode!(conn.resp_body) == %{"error" => "not found"}
  end
end
