# frozen_string_literal: true

require 'register_sources_oc/structs/reconciliation_request'

RSpec.describe RegisterSourcesOc::ReconciliationRequest do
  subject { described_class }

  context 'when given valid data' do
    let(:input_data) do
      {
        jurisdiction_code: 'gb',
        name: 'company name'
      }
    end

    it 'maps to struct correctly' do
      obj = described_class.new(input_data)

      expect(obj.jurisdiction_code).to eq 'gb'
      expect(obj.name).to eq 'company name'
    end
  end
end
