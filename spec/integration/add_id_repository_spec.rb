require 'elasticsearch'
require 'register_sources_oc/repositories/add_id_repository'
require 'register_sources_oc/services/es_index_creator'
require 'register_sources_oc/structs/add_id'

RSpec.describe RegisterSourcesOc::Repositories::AddIdRepository do
  subject { described_class.new(client: es_client, index: index) }

  let(:index) { SecureRandom.uuid }
  let(:es_client) do
    Elasticsearch::Client.new(
      host: "http://elastic:#{ENV['ELASTICSEARCH_PASSWORD']}@#{ENV['ELASTICSEARCH_HOST']}:#{ENV['ELASTICSEARCH_PORT']}",
      transport_options: { ssl: { verify: false } },
      log: false
    )
  end

  before do
    index_creator = RegisterSourcesOc::Services::EsIndexCreator.new(
      add_ids_index: index,
      client: es_client
    )
    index_creator.create_add_ids_index
  end

  describe '#store' do
    it 'stores' do
      records = [
        RegisterSourcesOc::AddId.new(
          company_number: '123456',
          jurisdiction_code: 'gb',
          uid: 'uid',
          identifier_system_code: 'identifier_system_code'
        )
      ]

      subject.store(records)

      sleep 1 # eventually consistent, give time

      results = subject.search_by_number(company_number: '123456', jurisdiction_code: 'gb')

      expect(results).not_to be_empty
      expect(results[0].record).to eq records[0]
    end
  end
end
