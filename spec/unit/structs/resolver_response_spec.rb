# frozen_string_literal: true

require 'register_sources_oc/structs/resolver_response'

RSpec.describe RegisterSourcesOc::ResolverResponse do
  subject { described_class }

  context 'when given valid data' do
    let(:input_data) do
      {
        resolved: true,
        reconciliation_response: {
          reconciled: true,
          company_number: '123456',
          jurisdiction_code: 'gb',
          name: 'company name'
        },
        company: {
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
      }
    end

    it 'maps to struct correctly' do
      obj = described_class.new(input_data)

      expect(obj.company).to be_a RegisterSourcesOc::Company
      expect(obj.reconciliation_response).to be_a RegisterSourcesOc::ReconciliationResponse
      expect(obj.resolved).to be true
    end
  end
end
