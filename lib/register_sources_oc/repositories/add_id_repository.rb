# frozen_string_literal: true

require 'digest'
require 'json'
require 'register_sources_oc/config/elasticsearch'
require 'register_sources_oc/structs/add_id'
require 'active_support/core_ext/hash/indifferent_access'

module RegisterSourcesOc
  module Repositories
    class AddIdRepository
      IDENTIFIER_SYSTEM_CODE_LEI = 'lei'

      SearchResult = Struct.new(:record, :score)

      def initialize(client: Config::ELASTICSEARCH_CLIENT, index: Config::ES_ADD_IDS_INDEX)
        @client = client
        @index = index
      end

      def search_by_number(jurisdiction_code:, company_number:)
        process_results(
          client.search(
            index:,
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
            index: {
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

      def each_lei(jurisdiction_codes: [], uids: [], &block)
        q_must = [{ term: { identifier_system_code: IDENTIFIER_SYSTEM_CODE_LEI } }]
        q_must << { terms: { jurisdiction_code: jurisdiction_codes } } unless jurisdiction_codes.empty?
        q_must << { terms: { uid: uids } } unless uids.empty?
        q = {
          index:,
          body: {
            query: {
              bool: {
                must: q_must
              }
            }
          }
        }
        search_scroll(q, &block)
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
            AddId.new(**source),
            hit['_score']
          )
        end

        mapped.sort_by(&:score).reverse
      end

      def search_scroll(query)
        response = client.search(**query, scroll: '10m')
        scroll_id = response['_scroll_id']
        response['hits']['hits'].each { |h| yield wrap_hit(h) }
        while response['hits']['hits'].size.positive?
          response = client.scroll(body: { scroll_id: }, scroll: '5m')
          response['hits']['hits'].each { |h| yield wrap_hit(h) }
        end
      end

      def wrap_hit(hit)
        AddId.new(JSON.parse(hit['_source'].to_json, symbolize_names: true))
      end
    end
  end
end
