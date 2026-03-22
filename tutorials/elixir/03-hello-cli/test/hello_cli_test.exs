defmodule HelloCliTest do
  use ExUnit.Case, async: true

  describe "parse_args/1" do
    test "parses --name flag" do
      assert HelloCli.parse_args(["--name", "Alice"]) == %{name: "Alice", shout: false}
    end

    test "parses --shout flag" do
      assert HelloCli.parse_args(["--shout"]) == %{name: "world", shout: true}
    end

    test "uses defaults when no args given" do
      assert HelloCli.parse_args([]) == %{name: "world", shout: false}
    end
  end

  describe "format/1" do
    test "returns uppercased greeting when shout is true" do
      assert HelloCli.format(%{name: "Elixir", shout: true}) == "HELLO, ELIXIR!"
    end

    test "returns normal greeting when shout is false" do
      assert HelloCli.format(%{name: "Elixir", shout: false}) == "Hello, Elixir!"
    end
  end
end
