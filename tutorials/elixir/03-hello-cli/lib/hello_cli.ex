defmodule HelloCli do
  @moduledoc """
  A minimal CLI that greets the user by name.
  """

  def main(argv) do
    argv
    |> parse_args()
    |> format()
    |> IO.puts()
  end

  def parse_args(argv) do
    {opts, _args, _invalid} =
      OptionParser.parse(argv, strict: [name: :string, shout: :boolean])

    %{
      name: Keyword.get(opts, :name, "world"),
      shout: Keyword.get(opts, :shout, false)
    }
  end

  def format(%{name: name, shout: true}) do
    "HELLO, #{String.upcase(name)}!"
  end

  def format(%{name: name}) do
    "Hello, #{name}!"
  end
end
