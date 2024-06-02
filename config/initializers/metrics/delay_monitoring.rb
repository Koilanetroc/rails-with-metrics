# frozen_string_literal: true

# Delay is measured by comparing point value(timestamp) with datapoint timestamp in VM

task = Concurrent::TimerTask.new(run_now: false, execution_interval: 1.minute) do
  Metrics.gauge("metrics_delivery_delay_check", Time.current.to_i)
end

task.execute
