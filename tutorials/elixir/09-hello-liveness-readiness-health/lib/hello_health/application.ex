defmodule HelloHealth.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HelloHealth.Checker,
      {Bandit, plug: HelloHealth.Router, port: 4003}
    ]

    opts = [strategy: :one_for_one, name: HelloHealth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
