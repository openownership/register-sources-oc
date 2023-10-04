# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesOc
  class Company < Dry::Struct
    transform_keys(&:to_sym)

    attribute :company_number,             Types::String.optional
    attribute :jurisdiction_code,          Types::String.optional
    attribute :name,                       Types::String.optional
    attribute :company_type,               Types::String.optional
    attribute :incorporation_date,         Types::String.optional
    attribute :dissolution_date,           Types::String.optional
    attribute :restricted_for_marketing,   Types::Strict::Bool.optional
    attribute :registered_address_in_full, Types::String.optional
    attribute :registered_address_country, Types::String.optional
  end
end
