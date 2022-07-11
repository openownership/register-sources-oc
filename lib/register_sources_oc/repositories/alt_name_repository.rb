require 'digest'
require 'json'
require 'register_sources_oc/config/elasticsearch'
require 'register_sources_oc/structs/alt_name'
require 'active_support/core_ext/hash/indifferent_access'

module RegisterSourcesOc
  module Repositories
    class AltNameRepository
      SearchResult = Struct.new(:record, :score)

      def initialize(client: Config::ELASTICSEARCH_CLIENT, index: Config::ES_ALT_NAMES_INDEX)
        @client = client
        @index = index
      end

      def search_by_number(jurisdiction_code:, company_number:)
        process_results(
          client.search(
            index: index,
            body: {
              query: {
                bool: {
                  must: [
                    {
                      match: {
                        company_number: {
                          query: company_number
                        }
                      }
                    },
                    {
                      match: {
                        jurisdiction_code: {
                          query: jurisdiction_code
                        }
                      }
                    }
                  ]
                }
              }
            }
          )
        )
      end

      def store(records)
        operations = records.map do |record|
          {
            index:  {
              _index: index,
              _id: calculate_id(record),
              data: record.to_h
            }
          }
        end

        result = client.bulk(body: operations)

        if result['errors']
          print result, "\n\n"
          raise 'error'
        end

        result
      end

      private

      attr_reader :client, :index

      def calculate_id(record)
        digest = Digest::SHA256.base64digest(record.to_h.to_json)[0...32]
        "#{record.jurisdiction_code}:#{record.company_number}:#{digest}"
      end

      def process_results(results)
        hits = results.dig('hits', 'hits') || []
        hits = hits.sort { |hit| hit['_score'] }.reverse

        mapped = hits.map do |hit|
          source = JSON.parse(hit['_source'].to_json, symbolize_names: true)

          SearchResult.new(
            AltName.new(**source),
            hit['_score']
          )
        end

        mapped.sort_by(&:score).reverse
      end
    end
  end
end
