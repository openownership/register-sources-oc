# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesOc
  class ReconciliationRequest < Dry::Struct
    transform_keys(&:to_sym)

    attribute :jurisdiction_code, Types::String
    attribute :name,              Types::String
  end
end
