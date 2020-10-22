# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-telemetry-sdk-ruby/blob/main/LICENSE for complete details.
require 'new_relic/telemetry_sdk/logger'

module NewRelic
  module TelemetrySdk
    class Harvester
      include NewRelic::TelemetrySdk::Logger

      attr_reader :interval

      def initialize interval = 5
        @interval = interval
        @harvestables = {}
        @shutdown = false
        @running = false
        @lock = Mutex.new
      end

      def register name, buffer, client
        @lock.synchronize do 
          @harvestables[name] = {
            buffer: buffer,
            client: client
          }
        end
      rescue => e
        log_error e, "Encountered error while registering buffer #{name}."
      end

      def [] name 
        @harvestables[name]
      end

      def running?
        @running
      end
      
      def start
        @running = true
        @harvest_thread = Thread.new do
          begin
            while !@shutdown do
              sleep @interval
              harvest
            end
            harvest
            @running = false
          rescue => e
            log_error e, "Encountered error in harvester"
          end
        end
      end

      def stop
        @shutdown = true
        @harvest_thread.join if @running
      rescue => e
        log_error e, "Encountered error stopping harvester"
      end

    private

      def harvest
        @lock.synchronize do
          @harvestables.values.each do |harvestable|
            process_harvestable harvestable
          end
        end
      end

      def process_harvestable harvestable
        batch = harvestable[:buffer].flush
        if !batch.nil? && batch[0].respond_to?(:any?) && batch[0].any?
          harvestable[:client].report_batch batch 
        end
      end

    end
  end
end
