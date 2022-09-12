require 'register_sources_oc/structs/resolver_request'
require 'register_sources_oc/services/resolver_service'

RSpec.describe RegisterSourcesOc::Services::ResolverService do
  subject do
    described_class.new(
      company_service: company_service,
      reconciliation_service: reconciliation_service
    )
  end

  let(:company_service) { double 'company_service' }
  let(:reconciliation_service) { double 'reconciliation_service' }
  let(:company) do
    RegisterSourcesOc::Company.new(
      company_number: '123456',
      jurisdiction_code: 'gb',
      name: 'company name',
      company_type: 'company_type',
      incorporation_date: '2020-01-09',
      dissolution_date: '2021-09-07',
      restricted_for_marketing: nil,
      registered_address_in_full: 'registered address',
      registered_address_country: 'country',
    )
  end

  describe '#resolve' do
    let(:jurisdiction_code) { 'gb' }
    let(:company_number) { '123456' }
    let(:name) { 'company_name' }
    let(:country) { 'country' }

    let(:resolver_request) do
      RegisterSourcesOc::ResolverRequest[{
        jurisdiction_code: jurisdiction_code,
        company_number: company_number,
        name: name,
        country: country,
      }.compact]
    end

    context 'when jurisdiction_code is nil' do
      let(:jurisdiction_code) { nil }

      context 'with country existing' do
        let(:fetched_jurisdiction_code) { 'fetched_code' }
        
        before do
          expect(company_service).to receive(:get_jurisdiction_code).with(country).and_return(
            fetched_jurisdiction_code
          )
          expect(company_service).to receive(:get_company).and_return company
        end

        it 'returns resolved record' do
          result = subject.resolve(resolver_request)
  
          expect(result).to be_a RegisterSourcesOc::ResolverResponse
          expect(result.reconciliation_response).to be_nil
          expect(result.resolved).to be true
          expect(result.company).to eq company
        end
      end

      context 'with country not matching a jurisdiction code' do
        before do
          expect(company_service).to receive(:get_jurisdiction_code).with(country).and_return nil
          expect(company_service).not_to receive(:get_company)
        end

        it 'retuns response with reconciled false' do
          result = subject.resolve(resolver_request)

          expect(result).to be_a RegisterSourcesOc::ResolverResponse
          expect(result.reconciliation_response).to be_nil
          expect(result.resolved).to be false
          expect(result.company).to be_nil
        end
      end
    end

    context 'when company_number missing' do
      let(:company_number) { nil }

      context 'without reconcilation_response' do
        before do
          expect(reconciliation_service).to receive(:reconcile).with(
            RegisterSourcesOc::ReconciliationRequest.new(
              jurisdiction_code: jurisdiction_code,
              name: name
            )
          ).and_return double('reconcilation_response', reconciled: false)
        end

        it 'returns unresolved record' do
          result = subject.resolve(resolver_request)

          expect(result).to be_a RegisterSourcesOc::ResolverResponse
          expect(result.reconciliation_response).to be_nil
          expect(result.resolved).to be false
          expect(result.company).to be_nil
        end
      end

      context 'with reconcilation_response' do
        let(:reconciled_company_number) { '901233' }

        before do
          expect(reconciliation_service).to receive(:reconcile).with(
            RegisterSourcesOc::ReconciliationRequest.new(
              jurisdiction_code: jurisdiction_code,
              name: name
            )
          ).and_return RegisterSourcesOc::ReconciliationResponse.new(
            jurisdiction_code: jurisdiction_code,
            company_number: reconciled_company_number,
            name: name,
            reconciled: true
          )

          expect(company_service).to receive(:get_company).and_return company
        end

        it 'uses reconciled company_number' do
          result = subject.resolve(resolver_request)

          expect(result).to be_a RegisterSourcesOc::ResolverResponse
          expect(result.reconciliation_response.reconciled).to eq true
          expect(result.reconciliation_response.company_number).to eq reconciled_company_number
          expect(result.resolved).to be true
          expect(result.company).to eq company
        end
      end
    end

    context 'when get_company returns a company' do
      before do
        expect(reconciliation_service).not_to receive(:reconcile)
        expect(company_service).to receive(:get_company).and_return company
      end

      it 'returns resolved record' do
        result = subject.resolve(resolver_request)

        expect(result).to be_a RegisterSourcesOc::ResolverResponse
        expect(result.reconciliation_response).to be_nil
        expect(result.resolved).to be true
        expect(result.company).to eq company
      end
    end

    context 'when get_company does not return a company' do
      before do
        expect(reconciliation_service).not_to receive(:reconcile)
        expect(company_service).to receive(:get_company).and_return nil
      end

      context 'with search_companies returning an empty list of companies' do        
        before do
          expect(company_service).to receive(:search_companies).and_return []
        end

        it 'returns resolved record' do
          result = subject.resolve(resolver_request)

          expect(result).to be_a RegisterSourcesOc::ResolverResponse
          expect(result.reconciliation_response).to be_nil
          expect(result.resolved).to be false
          expect(result.company).to be_nil
        end
      end

      context 'with search_companies returning a non-empty list of companies' do        
        before do
          expect(company_service).to receive(:search_companies).and_return [{ company: company }]
        end

        it 'returns resolved record' do
          result = subject.resolve(resolver_request)

          expect(result).to be_a RegisterSourcesOc::ResolverResponse
          expect(result.reconciliation_response).to be_nil
          expect(result.resolved).to be true
          expect(result.company).to eq company
        end
      end
    end
  end
end
