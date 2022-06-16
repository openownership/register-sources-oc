module RegisterSourcesOc
  module Services
    class BulkDataCompanyService
      DEFAULT_JURISDICTION_CODES = ['gb', 'sk', 'dk']

      def initialize(
        company_repository:,
        jurisdiction_codes: DEFAULT_JURISDICTION_CODES,
        repository_enabled: true
      )
        @company_repository = company_repository
        @jurisdiction_codes = jurisdiction_codes
        @repository_enabled = repository_enabled
      end

      def get_jurisdiction_code(name)
        nil # not supported - fall through
      end

      def get_company(jurisdiction_code, company_number, sparse: true)
        return unless repository_enabled
        return unless should_try_jurisdiction?(jurisdiction_code)

        results = company_repository.get(
          jurisdiction_code: jurisdiction_code,
          company_number: company_number
        )

        return if results.empty?
        
        results[0].record.to_h
      end

      def search_companies(jurisdiction_code, company_number)
        return unless repository_enabled
        return unless should_try_jurisdiction?(jurisdiction_code)

        results = company_repository.search_by_number(
          jurisdiction_code: jurisdiction_code,
          company_number: company_number
        )

        return if results.empty?

        results.map(&:record)
      end

      def search_companies_by_name(name)
        return unless repository_enabled

        results = company_repository.search_companies_by_name(name)

        return if results.empty?

        results.map(&:record)      
      end

      private

      attr_reader :company_repository, :jurisdiction_codes, :repository_enabled

      def should_try_jurisdiction?(jurisdiction_code)
        jurisdiction_codes.include? jurisdiction_code.downcase
      end
    end
  end
end
