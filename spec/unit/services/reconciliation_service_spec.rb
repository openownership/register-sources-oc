# frozen_string_literal: true

require 'register_sources_oc/structs/reconciliation_request'
require 'register_sources_oc/services/reconciliation_service'

RSpec.describe RegisterSourcesOc::Services::ReconciliationService do
  subject { described_class.new(reconciliation_client:) }

  let(:reconciliation_client) { double 'reconciliation_client' }

  describe '#reconcile' do
    let(:reconciliation_request) do
      RegisterSourcesOc::ReconciliationRequest.new(
        jurisdiction_code: 'gb',
        name: 'company_name'
      )
    end

    context 'when reconciliation_client returns nil response' do
      # rubocop:disable RSpec/ExpectInHook
      before do
        expect(reconciliation_client).to receive(:reconcile).with('gb', 'company_name').and_return nil
      end
      # rubocop:enable RSpec/ExpectInHook

      it 'retuns response with reconciled false' do
        result = subject.reconcile(reconciliation_request)

        expect(result).to be_a RegisterSourcesOc::ReconciliationResponse
        expect(result.reconciled).to be false
        expect(result.jurisdiction_code).to eq 'gb'
        expect(result.name).to eq 'company_name'
        expect(result.company_number).to be_nil
      end
    end

    context 'when reconciliation_client returns something' do
      let(:company_number) { 'abc123' }

      # rubocop:disable RSpec/ExpectInHook
      before do
        expect(reconciliation_client).to receive(:reconcile).with('gb', 'company_name').and_return(
          { company_number: }
        )
      end
      # rubocop:enable RSpec/ExpectInHook

      it 'retuns response with reconciled true' do
        result = subject.reconcile(reconciliation_request)

        expect(result).to be_a RegisterSourcesOc::ReconciliationResponse
        expect(result.reconciled).to be true
        expect(result.jurisdiction_code).to eq 'gb'
        expect(result.name).to eq 'company_name'
        expect(result.company_number).to eq company_number
      end
    end
  end
end
