# frozen_string_literal: true

require_relative '../clients/reconciliation_client'
require_relative '../structs/reconciliation_response'

module RegisterSourcesOc
  module Services
    class ReconciliationService
      def initialize(reconciliation_client: Clients::ReconciliationClient.new)
        @reconciliation_client = reconciliation_client
      end

      def reconcile(request)
        response = reconciliation_client.reconcile(request.jurisdiction_code, request.name)

        company_number = response&.fetch(:company_number)

        ReconciliationResponse.new(
          reconciled: !response.nil?,
          jurisdiction_code: request.jurisdiction_code,
          name: request.name,
          company_number:
        )
      end

      private

      attr_reader :reconciliation_client
    end
  end
end
