defmodule HelloOpenapi.MixProject do
  use Mix.Project

  def project do
    [
      app: :hello_openapi,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {HelloOpenapi.Application, []}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.16"},
      {:bandit, "~> 1.5"},
      {:jason, "~> 1.4"},
      {:open_api_spex, "~> 3.19"}
    ]
  end
end
