# frozen_string_literal: true

require 'elasticsearch'
require 'register_sources_oc/repository'
require 'register_sources_oc/services/es_index_creator'
require 'register_sources_oc/structs/add_id'

RSpec.describe RegisterSourcesOc::Repository do
  subject { described_class.new(RegisterSourcesOc::AddId, client: es_client, index:) }

  let(:index) { "tmp-#{SecureRandom.uuid}" }
  let(:es_client) { Elasticsearch::Client.new }

  before do
    index_creator = RegisterSourcesOc::Services::EsIndexCreator.new(client: es_client)
    index_creator.create_add_ids_index(index)
  end

  after do
    es_client.indices.delete(index:)
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
