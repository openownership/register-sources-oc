require 'dry-types'
require 'dry-struct'
require_relative 'company_result'

module RegisterSourcesOc
  module Types
    include Dry.Types()
  end

  class SearchCompaniesResponse < Dry::Struct
    attribute :companies, Types.Array(CompanyResult).optional
  end
end
