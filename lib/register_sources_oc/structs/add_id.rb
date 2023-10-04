# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesOc
  class AddId < Dry::Struct
    transform_keys(&:to_sym)

    attribute :company_number,         Types::String.optional
    attribute :jurisdiction_code,      Types::String.optional
    attribute :uid,                    Types::String.optional
    attribute :identifier_system_code, Types::String.optional
  end
end
