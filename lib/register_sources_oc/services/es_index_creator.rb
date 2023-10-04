# frozen_string_literal: true

require 'json'

require_relative '../config/elasticsearch'

module RegisterSourcesOc
  module Services
    class EsIndexCreator
      MAPPINGS_ADD_IDS   = JSON.parse(File.read(File.expand_path('mappings/add_ids.json', __dir__)))
      MAPPINGS_ALT_NAMES = JSON.parse(File.read(File.expand_path('mappings/alt_names.json', __dir__)))
      MAPPINGS_COMPANIES = JSON.parse(File.read(File.expand_path('mappings/companies.json', __dir__)))

      def initialize(
        client: Config::ELASTICSEARCH_CLIENT,
        companies_index: Config::ELASTICSEARCH_INDEX_COMPANIES,
        alt_names_index: Config::ELASTICSEARCH_INDEX_ALT_NAMES,
        add_ids_index: Config::ELASTICSEARCH_INDEX_ADD_IDS
      )
        @client = client
        @add_ids_index = add_ids_index
        @alt_names_index = alt_names_index
        @companies_index = companies_index
      end

      def create_add_ids_index
        client.indices.create index: add_ids_index, body: { mappings: MAPPINGS_ADD_IDS }
      end

      def create_alt_names_index
        client.indices.create index: alt_names_index, body: { mappings: MAPPINGS_ALT_NAMES }
      end

      def create_companies_index
        client.indices.create index: companies_index, body: { mappings: MAPPINGS_COMPANIES }
      end

      private

      attr_reader :client, :add_ids_index, :alt_names_index, :companies_index
    end
  end
end
