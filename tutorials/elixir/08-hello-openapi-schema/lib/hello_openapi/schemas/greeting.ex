defmodule HelloOpenapi.Schemas.Greeting do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Greeting",
    type: :object,
    required: [:message],
    properties: %{
      message: %Schema{type: :string, description: "The greeting message"}
    }
  })
end
