require 'elasticsearch'

module RegisterSourcesOc
  module Config
    ELASTICSEARCH_CLIENT = Elasticsearch::Client.new

    ES_ADD_IDS_INDEX   = 'add_ids'.freeze
    ES_ALT_NAMES_INDEX = 'alt_names'.freeze
    ES_COMPANIES_INDEX = 'companies'.freeze
  end
end
