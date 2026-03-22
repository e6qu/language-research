defmodule HelloLoggingTest do
  use ExUnit.Case, async: false

  @formatter {LoggerJSON.Formatters.Basic, metadata: :all}

  defp format_log(level, message, metadata \\ %{}) do
    log_event = %{
      level: level,
      msg: {:string, message},
      meta: Map.merge(%{time: System.system_time(:microsecond)}, metadata)
    }

    {formatter_mod, formatter_config} = @formatter
    formatter_mod.format(log_event, formatter_config)
    |> IO.iodata_to_binary()
    |> String.trim()
  end

  test "formatter output is valid JSON" do
    output = format_log(:info, "Processing order", %{order_id: 123})
    assert {:ok, _decoded} = Jason.decode(output)
  end

  test "JSON output contains message" do
    output = format_log(:info, "Processing order")
    decoded = Jason.decode!(output)
    assert decoded["message"] == "Processing order"
  end

  test "JSON output contains metadata keys" do
    output = format_log(:info, "Processing order", %{order_id: 123, user_id: "abc"})
    decoded = Jason.decode!(output)
    # LoggerJSON may nest metadata or flatten it depending on version
    has_order_id =
      decoded["order_id"] == 123 ||
        (is_map(decoded["metadata"]) && decoded["metadata"]["order_id"] == 123) ||
        get_in(decoded, ["meta", "order_id"]) == 123

    assert has_order_id, "Expected order_id=123 in: #{inspect(decoded)}"
  end

  test "different levels produce correct severity field" do
    warning_out = format_log(:warning, "Slow query")
    error_out = format_log(:error, "Connection failed")

    warning_decoded = Jason.decode!(warning_out)
    error_decoded = Jason.decode!(error_out)

    warning_level = warning_decoded["severity"] || warning_decoded["level"]
    error_level = error_decoded["severity"] || error_decoded["level"]

    assert warning_level in ["warning", "warn"]
    assert error_level == "error"
  end
end
