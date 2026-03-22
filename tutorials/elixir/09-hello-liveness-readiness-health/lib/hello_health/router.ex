defmodule HelloHealth.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/healthz" do
    send_json(conn, 200, %{status: "ok"})
  end

  get "/readyz" do
    case HelloHealth.Checker.status() do
      :ok -> send_json(conn, 200, %{status: "ok"})
      :degraded -> send_json(conn, 503, %{status: "degraded"})
    end
  end

  get "/health" do
    checks = HelloHealth.Checker.check_all()

    detail =
      checks
      |> Enum.into(%{}, fn {k, v} -> {k, %{status: Atom.to_string(v)}} end)

    status = if HelloHealth.Checker.status() == :ok, do: "ok", else: "degraded"

    send_json(conn, 200, %{status: status, checks: detail})
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  defp send_json(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end
end
