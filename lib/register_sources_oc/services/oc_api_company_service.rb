require 'forwardable'

require 'register_sources_oc/clients/open_corporate_client'

module RegisterSourcesOc
  module Services
    class OcApiCompanyService
      FIELDS = %i[company_number jurisdiction_code name company_type incorporation_date dissolution_date restricted_for_marketing registered_address_in_full registered_address_country].freeze

      extend Forwardable

      def_delegators :@open_corporate_client, :get_jurisdiction_code

      def initialize(open_corporate_client: Clients::OpenCorporateClient.new_for_imports)
        @open_corporate_client = open_corporate_client
      end

      def get_company(jurisdiction_code, company_number, sparse: true)
        result = open_corporate_client.get_company(jurisdiction_code, company_number, sparse:)
        map_result result
      end

      def search_companies(jurisdiction_code, company_number)
        results = open_corporate_client.search_companies(jurisdiction_code, company_number)

        return [] if results.empty?

        [{ company: map_result(results.first[:company]) }]
      end

      def search_companies_by_name(name)
        results = open_corporate_client.search_companies_by_name(name)

        return [] if results.empty?

        [{ company: map_result(results.first[:company]) }]
      end

      private

      attr_reader :open_corporate_client

      def map_result(result)
        return unless result

        FIELDS.to_h { |field| [field, result[field]] }
      end
    end
  end
end
