require 'register_sources_oc/services/oc_api_company_service'

RSpec.describe RegisterSourcesOc::Services::OcApiCompanyService do
  subject { described_class.new(open_corporate_client: open_corporate_client) }

  let(:open_corporate_client) { double 'open_corporate_client' }

  let(:expected_company) do
    {
      company_number: 'a1',
      jurisdiction_code: 'a2',
      name: 'a3',
      company_type: 'a4',
      incorporation_date: 'a5',
      dissolution_date: 'a6',
      restricted_for_marketing: 'a7',
      registered_address_in_full: 'a8'
    }
  end
  let(:oc_company) do
    expected_company.merge(
      some_other_field: 'a9'
    )
  end

  describe '#get_jurisdiction_code' do
    it 'calls open_corporate_client' do
      name = double 'name'

      expected_response = double('expected_response')
      expect(open_corporate_client).to receive(:get_jurisdiction_code).with(
        name
      ).and_return expected_response

      response = subject.get_jurisdiction_code name
      expect(response).to eq expected_response
    end
  end

  describe 'get_company' do
    it 'calls open_corporate_client' do
      jurisdiction_code = double 'jurisdiction_code'
      company_number = double 'company_number'
      sparse = double 'sparse'

      expect(open_corporate_client).to receive(:get_company).with(
        jurisdiction_code,
        company_number,
        sparse: sparse
      ).and_return oc_company

      response = subject.get_company(jurisdiction_code, company_number, sparse: sparse)
      expect(response).to eq expected_company
    end
  end

  describe 'search_companies' do
    let(:expected_response) do
      [{ company: oc_company}]
    end

    it 'calls open_corporate_client' do
      jurisdiction_code = double 'jurisdiction_code'
      company_number = double 'company_number'

      expect(open_corporate_client).to receive(:search_companies).with(
        jurisdiction_code,
        company_number
      ).and_return expected_response

      response = subject.search_companies(jurisdiction_code, company_number)
      expect(response).to eq [{ company: expected_company }]
    end
  end

  describe 'search_companies_by_name' do
    let(:expected_response) do
      [{ company: oc_company}]
    end

    it 'calls open_corporate_client' do
      name = double 'name'

      expect(open_corporate_client).to receive(:search_companies_by_name).with(
        name
      ).and_return expected_response

      response = subject.search_companies_by_name(name)
      expect(response).to eq [{ company: expected_company }]
    end
  end
end
