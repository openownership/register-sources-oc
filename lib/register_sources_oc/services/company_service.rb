# frozen_string_literal: true

require 'register_sources_oc/utils/result_comparer'

require_relative 'bulk_data_company_service'
require_relative 'oc_api_company_service'

module RegisterSourcesOc
  module Services
    class CompanyService
      InconsistentResponseError = Class.new(StandardError)

      # services: [ { name: 'bulk', service: bulk_service }, { name: 'oc_api', service: oc_api_service }]
      def initialize(services: nil, verbose: false, comparison_mode: false, comparer: nil)
        @services = services || [
          { name: 'bulk', service: BulkDataCompanyService.new },
          { name: 'api', service: OcApiCompanyService.new }
        ]
        @verbose = verbose
        @comparison_mode = comparison_mode
        @comparer = comparer || Utils::ResultComparer.new
      end

      def get_jurisdiction_code(name)
        try_services do |service|
          service.get_jurisdiction_code(name)
        end
      end

      def get_company(jurisdiction_code, company_number, sparse: true)
        try_services do |service|
          service.get_company(jurisdiction_code, company_number, sparse:)
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

      attr_reader :verbose, :services, :comparison_mode, :comparer

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

        comparison_mode ? comparer.compare_results(results) : result
      end
    end
  end
end
