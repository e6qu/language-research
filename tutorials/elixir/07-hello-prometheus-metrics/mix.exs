defmodule HelloMetrics.MixProject do
  use Mix.Project

  def project do
    [
      app: :hello_metrics,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {HelloMetrics.Application, []}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.16"},
      {:bandit, "~> 1.5"},
      {:jason, "~> 1.4"},
      {:telemetry_metrics_prometheus, "~> 1.1"},
      {:telemetry, "~> 1.2"}
    ]
  end
end
