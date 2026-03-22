defmodule HelloOpenapi.Application do
  use Application

  @impl true
  def start(_type, _args) do
    # Store the API spec so OpenApiSpex plugs can find it
    Application.put_env(:hello_openapi, :open_api_spex, HelloOpenapi.ApiSpec.spec())

    children = [
      {Bandit, plug: HelloOpenapi.Router, port: 4002}
    ]

    opts = [strategy: :one_for_one, name: HelloOpenapi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
