require 'dry-types'
require 'dry-struct'

module RegisterSourcesOc
  module Types
    include Dry.Types()
  end

  class AltName < Dry::Struct
    transform_keys(&:to_sym)

    attribute :company_number, Types::String.optional
    attribute :jurisdiction_code, Types::String.optional
    attribute :name, Types::String.optional
    attribute :type, Types::String.optional
    attribute :start_date, Types::String.optional
    attribute :end_date, Types::String.optional
  end
end
