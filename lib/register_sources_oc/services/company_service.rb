require_relative 'bulk_data_company_service'
require_relative 'oc_api_company_service'

module RegisterSourcesOc
  module Services
    class CompanyService
      InconsistentResponseError = Class.new(StandardError)

      # services: [ { name: 'bulk', service: bulk_service }, { name: 'oc_api', service: oc_api_service }]
      def initialize(services: nil, verbose: false, comparison_mode: false)
        @services = services || [
          { name: "bulk", service: BulkDataCompanyService.new },
          { name: "api", service: OcApiCompanyService.new }
        ]
        @verbose = verbose
        @comparison_mode = comparison_mode
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

      attr_reader :verbose, :services, :comparison_mode

      def try_services
        result = nil
        results = {}

        services.each do |service_h|
          service = service_h[:service]
          service_name = service_h[:name]

          result = yield service

          next unless result

          results[service_name] = result

          # Stop when we find a result unless we are comparing
          break if result && !comparison_mode
        end

        comparison_mode ? compare_results(results) : result
      end

      def compare_results(results)
        match_failures = []

        results.each do |service1, response1|
          results.each do |service2, response2|
            next unless service1 < service2
            next unless response1 != response2

            incorrect1 = get_non_matching_fields(response1, response2)
            incorrect2 = get_non_matching_fields(response2, response1)

            next unless incorrect1.empty? || incorrect2.empty?

            match_failures << {
              service1: service1,
              response1: incorrect1,
              service2: service2,
              response2: incorrect2
            }
          end
        end

        match_failures
      end

      def get_non_matching_fields(response1, response2)
        if response1.is_a?(Array) != response2.is_a?(Array)
          response1
        elsif response1.is_a?(Array)
          if response1.empty?
            {}
          elsif response2.empty?
            response1[0][:company]
          else
            get_non_matching_fields(response1[0][:company], response2[0][:company])
          end
        else
          response1.keys.map do |k|
            next if k == :registered_address_country
            next if response1[k] == response2[k]
            if (k == :registered_address_in_full)
              country = response1[:registered_address_country] || response2[:registered_address_country]
              next if [response1[k].to_s, country].join(', ') == response2[k]
              next if [response2[k].to_s, country].join(', ') == response1[k]
            end
            [k, response1[k]]
          end.compact.to_h
        end
      end
    end
  end
end
