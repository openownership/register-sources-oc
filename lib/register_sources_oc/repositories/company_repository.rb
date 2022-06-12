require 'digest'
require 'json'
require 'bods_sources_oc/structs/company'
require 'active_support/core_ext/hash/indifferent_access'

module RegisterSourcesOc
  module Repositories
    class CompanyRepository
      DEFAULT_INDEX = 'companies2'
      SearchResult = Struct.new(:record, :score)

      def initialize(client:, index: DEFAULT_INDEX)
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

      def search_by_name(jurisdiction_code:, name:)
        process_results(
          client.search(
            index: index,
            body: {
              query: {
                bool: {
                  must: [
                    {
                      query_string: { default_field: "name", query: name }
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
              _type: 'company',
              data: record.to_h
            }
          }
        end

        client.bulk(body: operations)
      end

      private

      attr_reader :client, :index

      def calculate_id(record)
        "#{record.jurisdiction_code}:#{record.company_number}"
      end

      def process_results(results)
        hits = results.dig('hits', 'hits') || []

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
