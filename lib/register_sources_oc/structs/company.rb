require 'dry-types'
require 'dry-struct'

module RegisterSourcesOc
  module Types
    include Dry.Types()
  end

  class RegisteredAddress < Dry::Struct
    attribute :street_address, Types::String.optional
    attribute :locality, Types::String.optional
    attribute :region, Types::String.optional
    attribute :postal_code, Types::String.optional
    attribute :country, Types::String.optional
    attribute :in_full, Types::String.optional
  end

  class Company < Dry::Struct
    attribute :company_number, Types::String.optional
    attribute :jurisdiction_code, Types::String.optional
    attribute :name, Types::String.optional
    attribute :normalised_name, Types::String.optional
    attribute :company_type, Types::String.optional
    attribute :nonprofit, Types::String.optional
    attribute :current_status, Types::String.optional
    attribute :incorporation_date, Types::String.optional
    attribute :dissolution_date, Types::String.optional
    attribute :branch, Types::String.optional
    attribute :business_number, Types::String.optional
    attribute :current_alternative_legal_name, Types::String.optional
    attribute :current_alternative_legal_name_language, Types::String.optional
    attribute :home_jurisdiction_text, Types::String.optional
    attribute :native_company_number, Types::String.optional
    attribute :previous_names, Types::String.optional
    attribute :alternative_names, Types::String.optional
    attribute :retrieved_at, Types::String.optional
    attribute :registry_url, Types::String.optional
    attribute :restricted_for_marketing, Types::String.optional
    attribute :inactive, Types::String.optional
    attribute :accounts_next_due, Types::String.optional
    attribute :accounts_reference_date, Types::String.optional
    attribute :accounts_last_made_up_date, Types::String.optional
    attribute :annual_return_next_due, Types::String.optional
    attribute :annual_return_last_made_up_date, Types::String.optional
    attribute :has_been_liquidated, Types::String.optional
    attribute :has_insolvency_history, Types::String.optional
    attribute :has_charges, Types::String.optional
    attribute :registered_address, RegisteredAddress.optional
    attribute :home_jurisdiction_code, Types::String.optional
    attribute :home_jurisdiction_company_number, Types::String.optional
    attribute :industry_code_uids, Types::String.optional
    attribute :latest_accounts_date, Types::String.optional
    attribute :latest_accounts_cash, Types::String.optional
    attribute :latest_accounts_assets, Types::String.optional
    attribute :latest_accounts_liabilities, Types::String.optional
  end
end
