# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module RegisterSourcesOc
  module Types
    include Dry.Types()
  end

  class ReconciliationRequest < Dry::Struct
    transform_keys(&:to_sym)

    attribute :jurisdiction_code, Types::String
    attribute :name, Types::String
  end
end
