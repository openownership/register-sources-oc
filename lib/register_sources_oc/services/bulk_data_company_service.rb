# frozen_string_literal: true

require 'elasticsearch'

require_relative '../repository'

module RegisterSourcesOc
  module Services
    class BulkDataCompanyService
      DEFAULT_JURISDICTION_CODES = %w[gb sk dk].freeze

      def initialize(
        company_repository: Repository.new(Company, id_digest: false, index: Config::ELASTICSEARCH_INDEX_COMPANIES),
        jurisdiction_codes: DEFAULT_JURISDICTION_CODES,
        repository_enabled: true
      )
        @company_repository = company_repository
        @jurisdiction_codes = jurisdiction_codes
        @repository_enabled = repository_enabled
      end

      def get_jurisdiction_code(_name)
        nil # not supported - fall through
      end

      # rubocop:disable Lint/UnusedMethodArgument
      def get_company(jurisdiction_code, company_number, sparse: true)
        return unless repository_enabled && jurisdiction_code

        jurisdiction_code = jurisdiction_code.downcase
        return unless should_try_jurisdiction?(jurisdiction_code)

        results = company_repository.get(
          jurisdiction_code:,
          company_number:
        )

        return if results.empty?

        results[0].record.to_h
      rescue Elasticsearch::Transport::Transport::Errors::BadRequest
        nil # fall through to next service
      end
      # rubocop:enable Lint/UnusedMethodArgument

      def search_companies(jurisdiction_code, company_number)
        return unless repository_enabled && jurisdiction_code

        jurisdiction_code = jurisdiction_code.downcase
        return unless should_try_jurisdiction?(jurisdiction_code)

        results = company_repository.search_by_number(
          jurisdiction_code:,
          company_number:
        )

        return if results.empty?

        [{ company: results.first.record.to_h }]
      rescue Elasticsearch::Transport::Transport::Errors::BadRequest
        nil # fall through to next service
      end

      def search_companies_by_name(name)
        return unless repository_enabled

        # return # TODO: disable for now

        results = company_repository.search_by_name(name)

        return if results.empty?

        [{ company: results.first.record.to_h }]
      rescue Elasticsearch::Transport::Transport::Errors::BadRequest
        nil # fall through to next service
      end

      private

      attr_reader :company_repository, :jurisdiction_codes, :repository_enabled

      def should_try_jurisdiction?(jurisdiction_code)
        jurisdiction_codes.include? jurisdiction_code
      end
    end
  end
end
