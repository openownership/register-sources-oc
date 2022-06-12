require 'dry-types'
require 'dry-struct'
require_relative 'company_result'

module RegisterSourcesOc
  module Types
    include Dry.Types()
  end

  class GetCompanyResponse < Dry::Struct
    attribute :company, CompanyResult
  end
end
