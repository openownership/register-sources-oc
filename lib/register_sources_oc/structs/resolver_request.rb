# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesOc
  class ResolverRequest < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :jurisdiction_code, Types::String
    attribute? :company_number,    Types::String
    attribute? :country,           Types::String
    attribute? :region,            Types::String.optional
    attribute? :name,              Types::String
  end
end
