defmodule HelloMetrics.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/work" do
    duration = Enum.random(1..500)

    :telemetry.execute([:hello, :work], %{duration: duration, count: 1}, %{})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{status: "ok", duration_ms: duration}))
  end

  get "/metrics" do
    metrics = TelemetryMetricsPrometheus.Core.scrape()

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, metrics)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
