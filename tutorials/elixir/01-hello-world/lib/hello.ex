defmodule Hello do
  @moduledoc """
  A simple greeting module.
  """

  @doc """
  Returns a generic greeting.
  """
  def greet, do: "Hello, world!"

  @doc """
  Returns a personalized greeting for `name`.
  """
  def greet(name), do: "Hello, #{name}!"
end
