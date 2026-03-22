defmodule HelloHealth.CheckerTest do
  use ExUnit.Case, async: false

  setup do
    # Reset state before each test
    HelloHealth.Checker.set_dependency(:database, :ok)
    HelloHealth.Checker.set_dependency(:cache, :ok)
    :ok
  end

  test "initial status is :ok" do
    assert HelloHealth.Checker.status() == :ok
  end

  test "status is :degraded after setting database to :error" do
    HelloHealth.Checker.set_dependency(:database, :error)
    assert HelloHealth.Checker.status() == :degraded
  end

  test "check_all returns full map" do
    result = HelloHealth.Checker.check_all()
    assert result == %{database: :ok, cache: :ok}
  end

  test "set_dependency updates the right dep" do
    HelloHealth.Checker.set_dependency(:cache, :error)
    result = HelloHealth.Checker.check_all()
    assert result[:cache] == :error
    assert result[:database] == :ok
  end
end
