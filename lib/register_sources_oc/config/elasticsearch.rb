# frozen_string_literal: true

require 'elasticsearch'

module RegisterSourcesOc
  module Config
    ELASTICSEARCH_CLIENT = Elasticsearch::Client.new

    ES_ADD_IDS_INDEX   = 'add_ids'
    ES_ALT_NAMES_INDEX = 'alt_names'
    ES_COMPANIES_INDEX = 'companies'
  end
end
