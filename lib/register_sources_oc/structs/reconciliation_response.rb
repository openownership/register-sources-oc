require 'dry-types'
require 'dry-struct'

module RegisterSourcesOc
  module Types
    include Dry.Types()
  end

  class ReconciliationResponse < Dry::Struct
    attribute :name, Types::String.optional
    attribute :jurisdiction_code, Types::String.optional
    attribute :company_number, Types::String.optional
  end
end
