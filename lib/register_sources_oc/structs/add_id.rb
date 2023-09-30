# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module RegisterSourcesOc
  module Types
    include Dry.Types()
  end

  class AddId < Dry::Struct
    transform_keys(&:to_sym)

    attribute :company_number, Types::String.optional
    attribute :jurisdiction_code, Types::String.optional
    attribute :uid, Types::String.optional
    attribute :identifier_system_code, Types::String.optional
  end
end
