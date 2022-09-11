require 'register_sources_oc/clients/reconciliation_client'
require 'register_sources_oc/structs/reconciliation_response'

module RegisterSourcesOc
  module Services
    class ReconciliationService
      def initialize(reconciliation_client: Clients::ReconciliationClient.new)
        @reconciliation_client = reconciliation_client
      end

      def reconcile(request)
        response = reconciliation_client.reconcile(request.jurisdiction_code, request.name)

        company_number = response && response.fetch(:company_number)

        ReconciliationResponse.new(
          reconciled: !response.nil?,
          jurisdiction_code: request.jurisdiction_code,
          name: request.name,
          company_number: company_number
        )
      end

      private

      attr_reader :reconciliation_client
    end
  end
end
