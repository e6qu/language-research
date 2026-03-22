defmodule HelloMetrics.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {TelemetryMetricsPrometheus, metrics: HelloMetrics.Telemetry.metrics()},
      {Bandit, plug: HelloMetrics.Router, port: 4001}
    ]

    opts = [strategy: :one_for_one, name: HelloMetrics.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
