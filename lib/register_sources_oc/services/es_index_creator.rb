# frozen_string_literal: true

require 'register_sources_oc/config/elasticsearch'

module RegisterSourcesOc
  module Services
    class EsIndexCreator
      def initialize(
        client: Config::ELASTICSEARCH_CLIENT,
        companies_index: Config::ES_COMPANIES_INDEX,
        alt_names_index: Config::ES_ALT_NAMES_INDEX,
        add_ids_index: Config::ES_ADD_IDS_INDEX
      )
        @client = client
        @companies_index = companies_index
        @alt_names_index = alt_names_index
        @add_ids_index = add_ids_index
      end

      def create_companies_index
        client.indices.create index: companies_index, body: {
          mappings: {
            properties: {
              company_number: {
                type: 'keyword'
              },
              jurisdiction_code: {
                type: 'keyword'
              },
              name: {
                type: 'text',
                fields: {
                  raw: {
                    type: 'keyword'
                  }
                }
              },
              company_type: {
                type: 'keyword'
              },
              incorporation_date: {
                type: 'keyword'
              },
              dissolution_date: {
                type: 'keyword'
              },
              restricted_for_marketing: {
                type: 'boolean'
              },
              registered_address_in_full: {
                type: 'text',
                fields: {
                  raw: {
                    type: 'keyword'
                  }
                }
              },
              registered_address_country: {
                type: 'keyword'
              }
            }
          }
        }
      end

      def create_add_ids_index
        client.indices.create index: add_ids_index, body: {
          mappings: {
            properties: {
              company_number: {
                type: 'keyword'
              },
              jurisdiction_code: {
                type: 'keyword'
              },
              uid: {
                type: 'keyword'
              },
              identifier_system_code: {
                type: 'keyword'
              }
            }
          }
        }
      end

      def create_alt_names_index
        client.indices.create index: alt_names_index, body: {
          mappings: {
            properties: {
              company_number: {
                type: 'keyword'
              },
              jurisdiction_code: {
                type: 'keyword'
              },
              name: {
                type: 'text',
                fields: {
                  raw: {
                    type: 'keyword'
                  }
                }
              },
              type: {
                type: 'keyword'
              },
              start_date: {
                type: 'keyword'
              },
              end_date: {
                type: 'keyword'
              }
            }
          }
        }
      end

      private

      attr_reader :client, :companies_index, :alt_names_index, :add_ids_index
    end
  end
end
