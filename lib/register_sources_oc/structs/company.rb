require 'dry-types'
require 'dry-struct'

module RegisterSourcesOc
  module Types
    include Dry.Types()
  end

  class Company < Dry::Struct
    attribute :company_number, Types::String.optional
    attribute :jurisdiction_code, Types::String.optional
    attribute :name, Types::String.optional
    attribute :company_type, Types::String.optional
    attribute :incorporation_date, Types::String.optional
    attribute :dissolution_date, Types::String.optional
    attribute :restricted_for_marketing, Types::String.optional
    attribute :registered_address_in_full, Types::String.optional
  end
end
