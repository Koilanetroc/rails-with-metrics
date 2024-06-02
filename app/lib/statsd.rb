# frozen_string_literal: true

require "datadog/statsd"

class Statsd
  include Singleton

  attr_reader :client

  def initialize
    @client = Datadog::Statsd.new(
      ENV["METRICS_VICTORIAMETRICS_ENDPOINT"],
      ENV["METRICS_VICTORIAMETRICS_PORT"],
      logger: Rails.logger
    )
  end
end
