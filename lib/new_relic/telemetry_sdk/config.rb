# encoding: utf-8
# frozen_string_literal: true
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-telemetry-sdk-ruby/blob/main/LICENSE for complete details.

module NewRelic
  module TelemetrySdk
    DEFAULT_TRACE_API_HOST = "https://trace-api.newrelic.com"
    DEFAULT_HARVEST_INTERVAL = 5
    DEFAULT_BACKOFF_FACTOR = 5
    DEFAULT_BACKOFF_MAX = 80
    DEFAULT_MAX_RETRIES = 8

    class Config
      attr_accessor :trace_api_host
      attr_accessor :logger
      attr_accessor :harvest_interval
      attr_accessor :api_insert_key
      attr_accessor :audit_logging_enabled
      attr_accessor :backoff_factor
      attr_accessor :backoff_max
      attr_accessor :max_retries

      def initialize
        @logger = Logger.logger
        @api_insert_key = ENV[API_INSERT_KEY]
        @audit_logging_enabled = false

        @trace_api_host = DEFAULT_TRACE_API_HOST
        @harvest_interval = DEFAULT_HARVEST_INTERVAL
        @backoff_factor = DEFAULT_BACKOFF_FACTOR
        @backoff_max = DEFAULT_BACKOFF_MAX
        @max_retries = DEFAULT_MAX_RETRIES
      end
    end
  end
end
