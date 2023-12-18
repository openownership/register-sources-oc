# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesOc
  class AltName < Dry::Struct
    transform_keys(&:to_sym)

    attribute  :company_number,    Types::String.optional
    attribute  :jurisdiction_code, Types::String.optional
    attribute  :name,              Types::String.optional
    attribute  :type,              Types::String.optional
    attribute  :start_date,        Types::String.optional
    attribute? :end_date,          Types::String.optional
  end
end
