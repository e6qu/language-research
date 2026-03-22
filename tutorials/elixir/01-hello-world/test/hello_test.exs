defmodule HelloTest do
  use ExUnit.Case, async: true

  test "greet/0 returns a generic greeting" do
    assert Hello.greet() == "Hello, world!"
  end

  test "greet/1 returns a personalized greeting" do
    assert Hello.greet("Alice") == "Hello, Alice!"
  end

  test "greet/1 handles an empty string" do
    assert Hello.greet("") == "Hello, !"
  end
end
