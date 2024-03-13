# frozen_string_literal: true

require 'elasticsearch'
require 'register_sources_oc/repository'
require 'register_sources_oc/services/es_index_creator'
require 'register_sources_oc/structs/alt_name'

RSpec.describe RegisterSourcesOc::Repository do
  subject { described_class.new(RegisterSourcesOc::AltName, client: es_client, index:) }

  let(:index) { "tmp-#{SecureRandom.uuid}" }
  let(:es_client) { Elasticsearch::Client.new }

  before do
    index_creator = RegisterSourcesOc::Services::EsIndexCreator.new(client: es_client)
    index_creator.create_alt_names_index(index)
  end

  after do
    es_client.indices.delete(index:)
  end

  describe '#store' do
    it 'stores' do
      records = [
        RegisterSourcesOc::AltName.new(
          company_number: '123456',
          jurisdiction_code: 'gb',
          name: 'name',
          type: 'type',
          start_date: '2020-07-06',
          end_date: '2021-02-27'
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
