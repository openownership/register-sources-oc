require 'elasticsearch'
require 'register_sources_oc/repositories/company_repository'
require 'register_sources_oc/services/es_index_creator'
require 'register_sources_oc/structs/company'

RSpec.describe RegisterSourcesOc::Repositories::CompanyRepository do
  subject { described_class.new(client: es_client, index:) }

  let(:index) { SecureRandom.uuid }
  let(:es_client) { Elasticsearch::Client.new }

  before do
    index_creator = RegisterSourcesOc::Services::EsIndexCreator.new(
      companies_index: index,
      client: es_client,
    )
    index_creator.create_companies_index
  end

  describe '#store' do
    it 'stores' do
      records = [
        RegisterSourcesOc::Company.new(
          company_number: '123456',
          jurisdiction_code: 'gb',
          name: 'company_name',
          company_type: 'company_type',
          incorporation_date: '2020-01-09',
          dissolution_date: '2021-09-07',
          restricted_for_marketing: nil,
          registered_address_in_full: 'registered address',
          registered_address_country: 'country',
        ),
      ]

      subject.store(records)

      sleep 1 # eventually consistent, give time

      results = subject.search_by_name('company_name')

      expect(results).not_to be_empty
      expect(results[0].record).to eq records[0]
    end
  end
end
