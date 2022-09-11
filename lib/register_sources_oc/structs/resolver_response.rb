require 'dry-types'
require 'dry-struct'

require_relative 'reconciliation_response'
require_relative 'company'

module RegisterSourcesOc
  module Types
    include Dry.Types()
  end

  class ResolverResponse < Dry::Struct
    transform_keys(&:to_sym)

    attribute :resolved, Types::Nominal::Bool.default(false)
    attribute? :reconciliation_response, ReconciliationResponse.optional
    attribute? :company, Company.optional
  end
end
