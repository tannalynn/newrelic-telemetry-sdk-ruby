# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-telemetry-sdk-ruby/blob/main/LICENSE for complete details.
# frozen_string_literal: true

require 'net/http'
require 'json'
require 'zlib'
require 'securerandom'

module NewRelic
  module TelemetrySdk
    class Client
      def initialize host:,
                     path:,
                     headers: {},
                     # Note: see whether anything should be sent
                     # via query params
                     query_params: nil,
                     use_gzip: true,
                     payload_type:
        @connection = set_up_connection host
        @path = construct_full_path path, query_params
        @headers = headers
        @gzip_request = use_gzip
        add_content_encoding_header @headers if @gzip_request
        @payload_type = payload_type
      end

      def send_request body
        body = JSON.generate body
        body = gzip_data body if @gzip_request
        @connection.post @path, body, @headers
      end

      def report batch, common_attributes=nil
        # We need to generate a version 4 uuid that will
        # be used for each unique batch, including on retries.
        # If a batch is split due to a 413 response,
        # each smaller batch should have its own.
        @headers['x-request-id'] = SecureRandom.uuid

        post_body = { @payload_type => [batch.to_h] }
        post_body["common_attributes"] = common_attributes if common_attributes
        response = send_request [post_body]

        return if response.is_a? Net::HTTPSuccess
        # Otherwise, take appropriate action based on response code
      end

      def add_content_encoding_header headers
        headers.merge!('content-encoding' => 'gzip')
      end

      def set_up_connection host
        uri = URI(host)
        conn = Net::HTTP.new uri.host, uri.port
        conn.use_ssl = true
        conn
      end

      def construct_full_path path, query_params
        return path unless query_params
        query_string = encode_query_params query_params
        "#{path}?#{query_string}"
      end

      def encode_query_params params
        URI.encode_www_form params
      end

      def gzip_data data
        Zlib.gzip data
      end
    end
  end
end