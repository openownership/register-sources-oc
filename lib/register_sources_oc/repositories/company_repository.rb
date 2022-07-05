require 'digest'
require 'json'
require 'register_sources_oc/config/elasticsearch'
require 'register_sources_oc/structs/company'
require 'active_support/core_ext/hash/indifferent_access'

module RegisterSourcesOc
  module Repositories
    class CompanyRepository
      DEFAULT_INDEX = 'companies'
      SearchResult = Struct.new(:record, :score)

      def initialize(client: Config::ELASTICSEARCH_CLIENT, index: DEFAULT_INDEX)
        @client = client
        @index = index
      end

      def get(jurisdiction_code:, company_number:)
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

      def search_by_name(name)
        process_results(
          client.search(
            index: index,
            body: {
              query: {
                bool: {
                  must: [
                    # { query_string: { default_field: "name", query: name } }
                    match: {
                      "name.raw": {
                        query: name
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
              # _type: 'company',
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
        "#{record.jurisdiction_code}:#{record.company_number}"
      end

      def process_results(results)
        hits = results.dig('hits', 'hits') || []
        hits = hits.sort { |hit| hit['_score'] }.reverse

        mapped = hits.map do |hit|
          source = JSON.parse(hit['_source'].to_json, symbolize_names: true)

          SearchResult.new(
            Company.new(**source),
            hit['_score']
          )
        end

        mapped.sort_by(&:score).reverse
      end
    end
  end
end
