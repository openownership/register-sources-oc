require 'elasticsearch'

module RegisterSourcesOc
  module Config
    MissingEsCredsError = Class.new(StandardError)

    raise MissingEsCredsError unless ENV['OC_ELASTICSEARCH_HOST']

    ELASTICSEARCH_CLIENT = Elasticsearch::Client.new(
      host: "#{ENV.fetch('OC_ELASTICSEARCH_PROTOCOL', 'http')}://elastic:#{ENV['OC_ELASTICSEARCH_PASSWORD']}@#{ENV['OC_ELASTICSEARCH_HOST']}:#{ENV['OC_ELASTICSEARCH_PORT']}",
      transport_options: { ssl: { verify: (ENV.fetch('OC_ELASTICSEARCH_SSL_VERIFY', false) == 'true') } },
      log: false
    )

    ES_COMPANIES_INDEX = 'companies'
    ES_ADD_IDS_INDEX = 'add_ids'
    ES_ALT_NAMES_INDEX = 'alt_names'
  end
end
