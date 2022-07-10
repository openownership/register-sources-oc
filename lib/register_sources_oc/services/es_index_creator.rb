require 'register_sources_oc/config/elasticsearch'

module RegisterSourcesOc
  module Services
    class EsIndexCreator
      def initialize(
        client: Config::ELASTICSEARCH_CLIENT,
        companies_index: Config::ES_COMPANIES_INDEX
      )
        @client = client
        @companies_index = companies_index
      end

      def create_index
        client.indices.create index: companies_index, body: { mappings: mappings }
      end

      private

      attr_reader :client, :companies_index

      def mappings
        {
          properties: {
            "company_number": {
              "type": "keyword"
            },
            "jurisdiction_code": {
              "type": "keyword"
            },
            "name": {
              "type": "text",
              "fields": {
                "raw": { 
                  "type":  "keyword"
                }
              }
            },
            "company_type": {
              "type": "keyword"
            },
            "incorporation_date": {
              "type": "keyword"
            },
            "dissolution_date": {
              "type": "keyword"
            },
            "restricted_for_marketing": {
              "type": "boolean"
            },
            "registered_address_in_full": {
              "type": "text",
              "fields": {
                "raw": { 
                  "type":  "keyword"
                }
              }
            },
            "registered_address_country": {
              "type": "keyword"
            },
          }
        }
      end
    end
  end
end
