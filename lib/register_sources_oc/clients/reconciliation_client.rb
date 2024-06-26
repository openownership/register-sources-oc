# frozen_string_literal: true

require 'cgi'
require 'json'
require 'logger'
require 'net/http/persistent'

module RegisterSourcesOc
  module Clients
    class ReconciliationClient
      Error = Class.new(StandardError)

      def initialize(logger: Logger.new($stdout))
        @http = Net::HTTP::Persistent.new(name: self.class.name)
        @http.proxy = URI(ENV.fetch('OC_PROXY')) if ENV['OC_PROXY']
        @logger = logger
      end

      def reconcile(jurisdiction_code, search_query)
        uri = URI("https://opencorporates.com/reconcile/#{jurisdiction_code}?query=" + escape(search_query))

        logger.info("Reconciling uri: #{uri}")

        response = @http.request(uri)

        results = parse(response).fetch(:result)

        return if results.empty?

        result = results.first

        %r{^/companies/(?<jurisdiction_code>[^/]+)/(?<company_number>[^/]+)$} =~ result.fetch(:id)

        {
          name: result.fetch(:name),
          jurisdiction_code:,
          company_number:
        }
      rescue StandardError => e
        logger.info("Received #{e.inspect} when reconciling \"#{search_query}\" (#{jurisdiction_code})")
        nil
      end

      private

      attr_reader :logger

      def parse(response)
        unless response.is_a?(Net::HTTPSuccess)
          raise Error, "unexpected #{response.code} response from opencorporates.com/reconcile"
        end

        JSON.parse(response.body, symbolize_names: true)
      end

      def escape(component)
        CGI.escape(component.to_s)
      end
    end
  end
end
