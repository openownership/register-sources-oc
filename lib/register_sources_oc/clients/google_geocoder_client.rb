# frozen_string_literal: true

require 'geokit'

require 'register_sources_oc/structs/geocoder_response'

module RegisterSourcesOc
  module Clients
    class GoogleGeocoderClient
      def initialize(api_key: nil, error_adapter: nil)
        @api_key = api_key || ENV.fetch('GOOGLE_GEOCODE_API_KEY', nil)
        @error_adapter = error_adapter

        return unless @api_key

        Geokit::Geocoders::GoogleGeocoder.api_key = @api_key
      end

      def jurisdiction(address_string)
        return unless api_key

        result = Geokit::Geocoders::GoogleGeocoder.geocode(address_string)
        return unless result.success?

        GeocoderResponse.new(
          country: result.country,
          country_code: result.country_code.downcase,
          state: result.state_name,
          state_code: result.state_code&.downcase
        )
      rescue StandardError => e
        error_adapter&.error(e)
        nil
      end

      private

      attr_reader :api_key, :error_adapter
    end
  end
end
