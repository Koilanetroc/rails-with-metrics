# frozen_string_literal: true

ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  format = event.payload[:format].to_s || "all"
  format = "all" if format == "*/*"

  tags = {
    controller: event.payload[:controller],
    action: event.payload[:action],
    format: format,
    status: event.payload[:status],
    method: event.payload[:method].to_s.downcase,
    exception: event.payload[:exception]&.first # Exception class
  }

  Metrics.increment("rails.request.total", tags: tags)
  Metrics.measure("rails.request.time", event.duration, tags: tags)
  Metrics.measure("rails.request.time.db", event.payload[:db_runtime] || 0, tags: tags)
end
