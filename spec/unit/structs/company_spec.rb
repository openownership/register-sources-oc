# frozen_string_literal: true

require 'register_sources_oc/structs/company'

RSpec.describe RegisterSourcesOc::Company do
  subject { described_class }

  context 'when given valid data' do
    let(:input_data) do
      {
        company_number: '123456',
        jurisdiction_code: 'gb',
        name: 'company name',
        company_type: 'company_type',
        incorporation_date: '2020-01-09',
        dissolution_date: '2021-09-07',
        restricted_for_marketing: nil,
        registered_address_in_full: 'registered address',
        registered_address_country: 'country'
      }
    end

    it 'maps to struct correctly' do
      obj = described_class.new(input_data)

      expect(obj.company_number).to eq '123456'
      expect(obj.jurisdiction_code).to eq 'gb'
      expect(obj.name).to eq 'company name'
      expect(obj.company_type).to eq 'company_type'
      expect(obj.incorporation_date).to eq '2020-01-09'
      expect(obj.dissolution_date).to eq '2021-09-07'
      expect(obj.restricted_for_marketing).to be_nil
      expect(obj.registered_address_in_full).to eq 'registered address'
      expect(obj.registered_address_country).to eq 'country'
    end
  end
end
