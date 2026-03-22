defmodule HelloOpenapi.ApiSpec do
  alias OpenApiSpex.{Info, Operation, PathItem, Server}
  alias HelloOpenapi.Schemas.Greeting

  def spec do
    %OpenApiSpex.OpenApi{
      info: %Info{title: "Hello API", version: "1.0.0"},
      servers: [%Server{url: "http://localhost:4002"}],
      paths: %{
        "/api/greet" => %PathItem{
          get: %Operation{
            summary: "Greet a user by name",
            operationId: "greetUser",
            parameters: [
              Operation.parameter(:name, :query, :string, "Name to greet", required: true)
            ],
            responses: %{
              200 => Operation.response("Greeting", "application/json", Greeting)
            }
          }
        },
        "/api/openapi" => %PathItem{
          get: %Operation{
            summary: "Get the OpenAPI spec",
            operationId: "getSpec",
            responses: %{
              200 => Operation.response("OpenAPI spec", "application/json", %OpenApiSpex.Schema{type: :object})
            }
          }
        }
      }
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
