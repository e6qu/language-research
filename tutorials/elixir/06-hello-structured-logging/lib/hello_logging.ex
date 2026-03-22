defmodule HelloLogging do
  require Logger

  @doc """
  Demonstrates structured logging at different levels with metadata.
  """
  def demo do
    Logger.info("Processing order", order_id: 123, user_id: "abc")
    Logger.warning("Slow query", duration_ms: 1500)
    Logger.error("Connection failed", service: "database")
  end
end
