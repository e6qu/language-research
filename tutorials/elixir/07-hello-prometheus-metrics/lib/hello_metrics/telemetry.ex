defmodule HelloMetrics.Telemetry do
  import Telemetry.Metrics

  def metrics do
    [
      counter("hello.work.count"),
      last_value("hello.work.duration", unit: :millisecond)
    ]
  end
end
