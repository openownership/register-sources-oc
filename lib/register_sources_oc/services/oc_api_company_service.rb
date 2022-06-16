require 'forwardable'

module RegisterSourcesOc
  module Services
    class OcApiCompanyService
      extend Forwardable

      def_delegators :@open_corporate_client,
        :get_jurisdiction_code,
        :get_company,
        :search_companies,
        :search_companies_by_name

      def initialize(open_corporate_client:)
        @open_corporate_client = open_corporate_client
      end

      private

      attr_reader :open_corporate_client
    end
  end
end
