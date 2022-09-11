require 'dry-types'
require 'dry-struct'

module RegisterSourcesOc
  module Types
    include Dry.Types()
  end

  class ResolverRequest < Dry::Struct
    transform_keys(&:to_sym)

    attribute :jurisdiction_code, Types::String.optional
    attribute :company_number, Types::String.optional
    attribute :country, Types::String.optional
    attribute :name, Types::String.optional
  end
end
