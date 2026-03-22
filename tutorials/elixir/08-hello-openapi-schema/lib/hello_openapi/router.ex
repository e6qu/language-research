defmodule HelloOpenapi.Router do
  use Plug.Router

  plug :match
  plug Plug.Parsers, parsers: [:json], json_decoder: Jason
  plug :dispatch

  get "/api/openapi" do
    spec = HelloOpenapi.ApiSpec.spec()
    json = Jason.encode!(spec)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, json)
  end

  get "/api/greet" do
    conn = fetch_query_params(conn)

    case conn.query_params do
      %{"name" => name} ->
        json = Jason.encode!(%{message: "Hello, #{name}!"})

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, json)

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{error: "Missing required parameter: name"}))
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
