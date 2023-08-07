require 'register_sources_oc/services/company_service'
require 'register_sources_oc/services/reconciliation_service'
require 'register_sources_oc/services/jurisdiction_code_service'

require 'register_sources_oc/structs/resolver_request'
require 'register_sources_oc/structs/resolver_response'
require 'register_sources_oc/structs/reconciliation_request'

module RegisterSourcesOc
  module Services
    class ResolverService
      def initialize(
        company_service: CompanyService.new,
        reconciliation_service: ReconciliationService.new,
        jurisdiction_code_service: JurisdictionCodeService.new
      )
        @company_service = company_service
        @reconciliation_service = reconciliation_service
        @jurisdiction_code_service = jurisdiction_code_service
      end

      def resolve(request)
        jurisdiction_code = request.jurisdiction_code

        unless jurisdiction_code
          country = request.country
          return ResolverResponse.new(resolved: false) unless country

          jurisdiction_code = jurisdiction_code_service.query_jurisdiction(country, region: request.region)
        end

        return ResolverResponse.new(resolved: false) unless jurisdiction_code

        company = nil
        company_number = request.company_number
        reconciliation_response = nil

        # Reconcile if necessary
        unless company_number
          reconciliation_response = reconcile(request, jurisdiction_code)

          return ResolverResponse.new(resolved: false, jurisdiction_code:) unless reconciliation_response.reconciled

          company_number = reconciliation_response.company_number
        end

        # Resolve
        response = company_service.get_company(jurisdiction_code, company_number)
        if response
          company = response
        else
          response = company_service.search_companies(jurisdiction_code, company_number)
          unless response.empty?
            company = response.first.fetch(:company)
          end
        end

        ResolverResponse[{
          resolved: !company.nil?,
          jurisdiction_code:,
          company_number:,
          reconciliation_response:,
          company:,
        }.compact]
      end

      private

      attr_reader :company_service, :reconciliation_service, :jurisdiction_code_service

      def reconcile(request, jurisdiction_code)
        reconciliation_service.reconcile(
          ReconciliationRequest.new(
            jurisdiction_code:,
            name: request.name,
          ),
        )
      end
    end
  end
end
