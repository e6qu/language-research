defmodule HelloCliBurrito.MixProject do
  use Mix.Project

  def project do
    [
      app: :hello_cli,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {HelloCli.App, []}]
  end

  defp deps do
    [{:burrito, "~> 1.5"}]
  end

  defp releases do
    [
      hello_cli: [
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            macos: [os: :darwin, cpu: :aarch64]
          ]
        ]
      ]
    ]
  end
end
