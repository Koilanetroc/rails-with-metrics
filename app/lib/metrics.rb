# frozen_string_literal: true

class Metrics
  # encoding is needed to save extra traffic
  AGGREGATION_TYPE_ENCODING = {
    measurement: 1,
    gauge: 2,
    counter: 3
  }.freeze

  class << self
    def measure(name, value, aggregation_type: :measurement, tags: {})
      Statsd.instance.client.gauge(name, value, tags: tags.merge(ag_t: AGGREGATION_TYPE_ENCODING.fetch(aggregation_type)))
    end

    def gauge(name, value, aggregation_type: :gauge, tags: {})
      Statsd.instance.client.gauge(name, value, tags: tags.merge(ag_t: AGGREGATION_TYPE_ENCODING.fetch(aggregation_type)))
    end

    def increment(name, by: 1, aggregation_type: :counter, tags: {})
      Statsd.instance.client.increment(name, by: by, tags: tags.merge(ag_t: AGGREGATION_TYPE_ENCODING.fetch(aggregation_type)))
    end

    def close
      Statsd.instance.client.close(flush: true)
    end

    def timing(name, **options, &block)
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      begin
        block.call
      ensure
        measure(name, Process.clock_gettime(Process::CLOCK_MONOTONIC) - start, **options)
      end
    end
  end
end
