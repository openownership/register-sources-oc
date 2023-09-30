# frozen_string_literal: true

require 'register_sources_oc/clients/open_corporate_client'
require 'register_sources_oc/clients/google_geocoder_client'

module RegisterSourcesOc
  module Services
    class JurisdictionCodeService
      def initialize(geocoder_client: Clients::GoogleGeocoderClient.new,
                     open_corporate_client: Clients::OpenCorporateClient.new_for_imports)
        @geocoder_client = geocoder_client
        @open_corporate_client = open_corporate_client
        @cache = {}
      end

      def query_jurisdiction(country, region: nil)
        cache_key = "#{country}:#{region}"

        return cache[cache_key] if cache[cache_key]

        cache[cache_key] = query_jurisdiction_no_cache(country, region:)
      end

      def clear_cache
        @cache = {}
      end

      private

      attr_reader :geocoder_client, :open_corporate_client, :cache

      def query_jurisdiction_no_cache(country, region: nil)
        jurisdiction_response = geocoder_client.jurisdiction([region, country].compact.map(&:to_s).join(', '))
        jurisdiction_code = nil

        if jurisdiction_response
          state_or_country = jurisdiction_response.state || jurisdiction_response.country
          jurisdiction_code = state_or_country && open_corporate_client.get_jurisdiction_code(state_or_country)
          return jurisdiction_code if jurisdiction_code
        end

        open_corporate_client.get_jurisdiction_code(country)
      end
    end
  end
end
