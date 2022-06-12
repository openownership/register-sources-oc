require 'register_sources_oc/structs/reconciliation_response'

module RegisterSourcesOc
  module Services
    class CompanyService
      def initialize(company_repository:)
        @company_repository = company_repository
      end

      # Use to find company number from jurisdiction code and name
      def reconcile(jurisdiction_code:, company_name:)

      end

      def get_company(jurisdiction_code:, company_number:)

      end

      # Fuzzy matching - orders by score and picks best
      def search_companies_by_company_number(jurisdiction_code:, company_number:)

      end

      # Fuzzy matching - orders by score and picks best
      def search_companies_by_company_name(jurisdiction_code:, company_name:)

      end

      private

      attr_reader :company_repository
    end
  end
end
