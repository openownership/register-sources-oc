require 'register_sources_oc/structs/reconciliation_response'

RSpec.describe RegisterSourcesOc::ReconciliationResponse do
  subject { described_class }

  context 'when given valid data' do
    let(:input_data) do
      {
        reconciled: true,
        company_number: '123456',
        jurisdiction_code: 'gb',
        name: 'company name',
      }
    end

    it 'maps to struct correctly' do
      obj = described_class.new(input_data)

      expect(obj.reconciled).to be true
      expect(obj.company_number).to eq '123456'
      expect(obj.jurisdiction_code).to eq 'gb'
      expect(obj.name).to eq 'company name'
    end
  end
end
