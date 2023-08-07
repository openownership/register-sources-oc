require 'elasticsearch'

module RegisterSourcesOc
  module Config
    MissingEsCredsError = Class.new(StandardError)

    raise MissingEsCredsError unless ENV['ELASTICSEARCH_HOST']

    ELASTICSEARCH_CLIENT = Elasticsearch::Client.new(
      host: "#{ENV.fetch('ELASTICSEARCH_PROTOCOL', 'http')}://elastic:#{ENV.fetch('ELASTICSEARCH_PASSWORD', nil)}@#{ENV.fetch('ELASTICSEARCH_HOST', nil)}:#{ENV.fetch('ELASTICSEARCH_PORT', nil)}",
      transport_options: { ssl: { verify: (ENV.fetch('ELASTICSEARCH_SSL_VERIFY', false) == 'true') } },
      log: false,
    )

    ES_COMPANIES_INDEX = 'companies'.freeze
    ES_ADD_IDS_INDEX = 'add_ids'.freeze
    ES_ALT_NAMES_INDEX = 'alt_names'.freeze
  end
end
