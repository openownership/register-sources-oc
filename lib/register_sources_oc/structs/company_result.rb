require 'dry-types'
require 'dry-struct'
require_relative 'company_short'

module RegisterSourcesOc
  module Types
    include Dry.Types()
  end

  class CompanyResult < Dry::Struct
    attribute :resource, CompanyShort
    attribute :score, Types::String.optional # how well it matches query
  end
end
