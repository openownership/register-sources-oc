# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module RegisterSourcesOc
  module Types
    include Dry.Types()
  end

  class ReconciliationResponse < Dry::Struct
    transform_keys(&:to_sym)

    attribute :reconciled, Types::Nominal::Bool.optional
    attribute :jurisdiction_code, Types::String
    attribute :name, Types::String
    attribute :company_number, Types::String.optional
  end
end
