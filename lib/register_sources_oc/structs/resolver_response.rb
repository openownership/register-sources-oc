# frozen_string_literal: true

require_relative '../types'
require_relative 'add_id'
require_relative 'alt_name'
require_relative 'company'
require_relative 'reconciliation_response'

module RegisterSourcesOc
  class ResolverResponse < Dry::Struct
    transform_keys(&:to_sym)

    attribute  :resolved,                Types::Nominal::Bool.default(false)
    attribute? :jurisdiction_code,       Types::String
    attribute? :company_number,          Types::String
    attribute? :reconciliation_response, ReconciliationResponse.optional
    attribute? :company,                 Company.optional
    attribute? :add_ids,                 Types.Array(AddId)
    attribute? :alt_names,               Types.Array(AltName)
  end
end
