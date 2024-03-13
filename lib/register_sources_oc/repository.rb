# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'digest'
require 'json'

require_relative 'config/elasticsearch'

module RegisterSourcesOc
  class Repository
    SearchResult = Struct.new(:record, :score)

    def initialize(struct, id_digest: true, client: Config::ELASTICSEARCH_CLIENT, index: nil)
      @struct = struct
      @id_digest = id_digest
      @client = client
      @index = index
    end

    def get(jurisdiction_code:, company_number:)
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
                        query: company_number.upcase
                      }
                    }
                  },
                  {
                    match: {
                      jurisdiction_code: {
                        query: jurisdiction_code.downcase
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
          index:,
          body: {
            query: {
              bool: {
                must: [
                  {
                    match: {
                      company_number: {
                        query: company_number.upcase
                      }
                    }
                  },
                  {
                    match: {
                      jurisdiction_code: {
                        query: jurisdiction_code.downcase
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
          index:,
          body: {
            query: {
              bool: {
                must: [
                  match: {
                    'name.raw': {
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

    private

    attr_reader :client, :index

    def calculate_id(record)
      if @id_digest
        digest = Digest::SHA256.base64digest(record.to_h.to_json)[0...32]
        "#{record.jurisdiction_code}:#{record.company_number}:#{digest}"
      else
        "#{record.jurisdiction_code}:#{record.company_number}"
      end
    end

    def process_results(results)
      hits = results.dig('hits', 'hits') || []
      hits = hits.sort { |hit| hit['_score'] }.reverse # rubocop:disable Lint/UnexpectedBlockArity # FIXME
      mapped = hits.map do |hit|
        source = JSON.parse(hit['_source'].to_json, symbolize_names: true)
        SearchResult.new(@struct.new(**source), hit['_score'])
      end
      mapped.sort_by(&:score).reverse
    end
  end
end
