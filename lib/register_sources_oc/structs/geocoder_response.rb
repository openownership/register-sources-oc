# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesOc
  class GeocoderResponse < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :country,      Types::String
    attribute? :country_code, Types::String
    attribute? :state,        Types::String.optional
    attribute? :state_code,   Types::String.optional
  end
end
