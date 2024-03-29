# frozen_string_literal: true

require_relative '../repository'
require_relative '../structs/reconciliation_request'
require_relative '../structs/resolver_request'
require_relative '../structs/resolver_response'
require_relative 'company_service'
require_relative 'jurisdiction_code_service'
require_relative 'reconciliation_service'

module RegisterSourcesOc
  module Services
    class ResolverService
      def initialize(
        company_service: CompanyService.new,
        reconciliation_service: ReconciliationService.new,
        jurisdiction_code_service: JurisdictionCodeService.new,
        add_id_repository: Repository.new(AddId, index: Config::ELASTICSEARCH_INDEX_ADD_IDS),
        alt_name_repository: Repository.new(AltName, index: Config::ELASTICSEARCH_INDEX_ALT_NAMES)
      )
        @company_service = company_service
        @reconciliation_service = reconciliation_service
        @jurisdiction_code_service = jurisdiction_code_service
        @add_id_repository = add_id_repository
        @alt_name_repository = alt_name_repository
      end

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
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
          company = response.first.fetch(:company) unless response.empty?
        end

        add_ids = @add_id_repository.search_by_number(
          jurisdiction_code:, company_number:
        ).map(&:record)

        alt_names = @alt_name_repository.search_by_number(
          jurisdiction_code:, company_number:
        ).map(&:record)

        ResolverResponse[{
          resolved: !company.nil?,
          jurisdiction_code:,
          company_number:,
          reconciliation_response:,
          company:,
          add_ids:,
          alt_names:
        }.compact]
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      private

      attr_reader :company_service, :reconciliation_service, :jurisdiction_code_service

      def reconcile(request, jurisdiction_code)
        reconciliation_service.reconcile(
          ReconciliationRequest.new(
            jurisdiction_code:,
            name: request.name
          )
        )
      end
    end
  end
end
