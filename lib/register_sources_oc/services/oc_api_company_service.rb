module RegisterSourcesOc
  module Services
    class OcApiCompanyService
      def initialize(open_corporate_client:)
        @open_corporate_client = open_corporate_client
      end

      def get_jurisdiction_code(name)
        open_corporate_client.get_jurisdiction_code name
      end

      def get_company(jurisdiction_code, company_number, sparse: true)
        open_corporate_client.get_company(
          jurisdiction_code,
          company_number,
          sparse: sparse
        )
      end

      def search_companies(jurisdiction_code, company_number)
        open_corporate_client.search_companies(
          jurisdiction_code,
          company_number
        )
      end

      def search_companies_by_name(name)
        open_corporate_client.search_companies_by_name(name)
      end

      private

      attr_reader :open_corporate_client
    end
  end
end
