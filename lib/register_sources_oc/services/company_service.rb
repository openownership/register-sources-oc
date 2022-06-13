module RegisterSourcesOc
  module Services
    class CompanyService
      # services: [ { name: 'bulk', service: bulk_service }, { name: 'oc_api', service: oc_api_service }]
      def initialize(services:, verbose: false)
        @services = services
        @verbose = verbose
      end

      def get_jurisdiction_code(name)
        try_services do |service|
          service.get_jurisdiction_code(name)
        end
      end

      def get_company(jurisdiction_code, company_number, sparse: true)
        try_services do |service|
          service.get_company(jurisdiction_code, company_number, sparse: sparse)
        end
      end

      def search_companies(jurisdiction_code, company_number)
        try_services do |service|
          service.search_companies(jurisdiction_code, company_number)
        end
      end

      def search_companies_by_name(name)
        try_services do |service|
          service.search_companies_by_name(name)
        end
      end

      private

      attr_reader :verbose, :services

      def try_services
        result = nil
        services.each do |service_h|
          name = service_h[:name]
          service = service_h[:service]

          print("TRYING SERVICE #{name}\n") if verbose
          result = yield service
          print(result ? "FOUND\n" : "NOT FOUND\n" ) if verbose
          break if result
        end

        result
      end
    end
  end
end
