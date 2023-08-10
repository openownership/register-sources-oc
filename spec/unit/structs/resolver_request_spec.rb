require 'register_sources_oc/structs/resolver_request'

RSpec.describe RegisterSourcesOc::ResolverRequest do
  subject { described_class }

  context 'when given valid data' do
    let(:input_data) do
      {
        company_number: '123456',
        jurisdiction_code: 'gb',
        country: 'country',
        name: 'company name',
      }
    end

    it 'maps to struct correctly' do
      obj = described_class.new(input_data)

      expect(obj.company_number).to eq '123456'
      expect(obj.jurisdiction_code).to eq 'gb'
      expect(obj.country).to eq 'country'
      expect(obj.name).to eq 'company name'
    end
  end
end
