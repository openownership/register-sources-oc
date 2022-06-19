require 'register_sources_oc/services/bulk_data_company_service'

RSpec.describe RegisterSourcesOc::Services::BulkDataCompanyService do
  subject do
    described_class.new(
      company_repository: company_repository,
      jurisdiction_codes: jurisdiction_codes,
      repository_enabled: repository_enabled
    )
  end

  let(:company_repository) { double 'company_repository' }
  let(:jurisdiction_codes) { ['gb', 'fr'] }
  let(:repository_enabled) { true }

  describe '#get_jurisdiction_code' do
    it 'returns nil' do
      name = double 'name'
      result = subject.get_jurisdiction_code(name)
      expect(result).to be_nil
    end
  end

  describe '#get_company' do
    let(:jurisdiction_code) { jurisdiction_codes[0] }
    let(:company_number) { double 'company_number' }
    let(:sparse) { double 'sparse' }

    context 'when repository is not enabled' do
      let(:repository_enabled) { false }

      it 'returns nil' do
        result = subject.get_company(jurisdiction_code, company_number, sparse: sparse)
        expect(result).to be_nil
      end
    end

    context 'when jurisdiction_code is not in list' do
      let(:jurisdiction_code) { 'unknown' }

      it 'returns nil' do
        result = subject.get_company(jurisdiction_code, company_number, sparse: sparse)
        expect(result).to be_nil
      end
    end

    context 'when repository enabled with jurisdiction code in list' do
      let(:results) do
        [
          double(record: { r1: 'r1' }, score: 5.6),
          double(record: { r2: 'r2' }, score: 5.2)
        ]
      end

      before do
        expect(company_repository).to receive(:get).with(
          jurisdiction_code: jurisdiction_code,
          company_number: company_number  
        ).and_return results
      end

      context 'with results empty' do
        let(:results) { [] }

        it 'returns nil' do
          result = subject.get_company(jurisdiction_code, company_number, sparse: sparse)
          expect(result).to be_nil
        end
      end

      context 'with results non-empty' do
        it 'returns record of first result' do
          result = subject.get_company(jurisdiction_code, company_number, sparse: sparse)
          expect(result).to eq({ r1: 'r1' })
        end
      end
    end
  end

  describe '#search_companies' do
    let(:jurisdiction_code) { jurisdiction_codes[0] }
    let(:company_number) { double 'company_number' }

    context 'when repository is not enabled' do
      let(:repository_enabled) { false }

      it 'returns nil' do
        result = subject.search_companies(jurisdiction_code, company_number)
        expect(result).to be_nil
      end
    end

    context 'when jurisdiction_code is not in list' do
      let(:jurisdiction_code) { 'unknown' }

      it 'returns nil' do
        result = subject.search_companies(jurisdiction_code, company_number)
        expect(result).to be_nil
      end
    end

    context 'when repository enabled with jurisdiction code in list' do
      let(:results) do
        [
          double(record: { r1: 'r1' }, score: 5.6),
          double(record: { r2: 'r2' }, score: 5.2)
        ]
      end

      before do
        expect(company_repository).to receive(:search_by_number).with(
          jurisdiction_code: jurisdiction_code,
          company_number: company_number
        ).and_return results
      end

      context 'with results empty' do
        let(:results) { [] }

        it 'returns nil' do
          result = subject.search_companies(jurisdiction_code, company_number)
          expect(result).to be_nil
        end
      end

      context 'with results non-empty' do
        it 'returns record of first result' do
          result = subject.search_companies(jurisdiction_code, company_number)
          expect(result).to eq [{ r1: 'r1' }, { r2: 'r2' }]
        end
      end
    end
  end

  describe '#search_companies_by_name' do
    let(:name) { double 'name' }

    context 'when repository is not enabled' do
      let(:repository_enabled) { false }

      it 'returns nil' do
        result = subject.search_companies_by_name(name)
        expect(result).to be_nil
      end
    end

    context 'when repository enabled' do
      let(:results) do
        [
          double(record: { r1: 'r1' }, score: 5.6),
          double(record: { r2: 'r2' }, score: 5.2)
        ]
      end

      before do
        expect(company_repository).to receive(:search_companies_by_name).with(
          name
        ).and_return results
      end

      context 'with results empty' do
        let(:results) { [] }

        it 'returns nil' do
          result = subject.search_companies_by_name(name)
          expect(result).to be_nil
        end
      end

      context 'with results non-empty' do
        it 'returns record of first result' do
          result = subject.search_companies_by_name(name)
          expect(result).to eq [{ r1: 'r1' }, { r2: 'r2' }]
        end
      end
    end
  end
end
