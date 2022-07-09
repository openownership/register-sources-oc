require 'elasticsearch'

module RegisterSourcesOc
  module Config
    MissingEsCredsError = Class.new(StandardError)

    raise MissingEsCredsError unless ENV['ELASTICSEARCH_HOST']

    ELASTICSEARCH_CLIENT = Elasticsearch::Client.new(
      host: "#{ENV.fetch('ELASTICSEARCH_PROTOCOL', 'http')}://elastic:#{ENV['ELASTICSEARCH_PASSWORD']}@#{ENV['ELASTICSEARCH_HOST']}:#{ENV['ELASTICSEARCH_PORT']}",
      transport_options: { ssl: { verify: ENV.fetch('ELASTICSEARCH_SSL_VERIFY', false) } },
      log: false
    )
  end
end
