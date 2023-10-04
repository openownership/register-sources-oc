# frozen_string_literal: true

require 'elasticsearch'

module RegisterSourcesOc
  module Config
    ELASTICSEARCH_CLIENT          = Elasticsearch::Client.new
    ELASTICSEARCH_INDEX_ADD_IDS   = 'add_ids'
    ELASTICSEARCH_INDEX_ALT_NAMES = 'alt_names'
    ELASTICSEARCH_INDEX_COMPANIES = 'companies'
  end
end
