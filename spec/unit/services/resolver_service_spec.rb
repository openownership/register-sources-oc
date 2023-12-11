# frozen_string_literal: true

require 'register_sources_oc/structs/resolver_request'
require 'register_sources_oc/services/resolver_service'

RSpec.describe RegisterSourcesOc::Services::ResolverService do
  subject do
    described_class.new(
      company_service:,
      reconciliation_service:,
      jurisdiction_code_service:,
      add_id_repository:,
      alt_name_repository:
    )
  end

  let(:company_service) { double 'company_service' }
  let(:reconciliation_service) { double 'reconciliation_service' }
  let(:jurisdiction_code_service) { double 'jurisdiction_code_service' }
  let(:add_id_repository) { double 'add_id_repository' }
  let(:alt_name_repository) { double 'alt_name_repository' }

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
      registered_address_country: 'country'
    )
  end

  let(:add_ids) do
    [
      RegisterSourcesOc::AddId.new(jurisdiction_code: 'gb', company_number: '123456', identifier_system_code: 'lei',
                                   uid: '00MQKGBWLLX0RPPDO000')
    ]
  end

  let(:alt_names) do
    [
      RegisterSourcesOc::AltName.new(company_number: '38284967', jurisdiction_code: 'dk',
                                     name: 'A.P. Moller Capital P/S', start_date: '2017-08-08', type: 'trading')
    ]
  end

  describe '#resolve' do
    let(:jurisdiction_code) { 'gb' }
    let(:company_number) { '123456' }
    let(:name) { 'company_name' }
    let(:country) { 'country' }
    let(:region) { nil }

    let(:resolver_request) do
      RegisterSourcesOc::ResolverRequest[{
        jurisdiction_code:,
        company_number:,
        name:,
        country:,
        region:
      }.compact]
    end

    context 'when jurisdiction_code is nil' do
      let(:jurisdiction_code) { nil }

      context 'with country existing' do
        let(:fetched_jurisdiction_code) { 'fetched_code' }

        # rubocop:disable RSpec/ExpectInHook
        before do
          expect(jurisdiction_code_service).to receive(:query_jurisdiction).with(country, region: nil).and_return 'ca'
          expect(company_service).to receive(:get_company).and_return company
          expect(add_id_repository).to receive(:search_by_number).with({ jurisdiction_code: 'ca',
                                                                         company_number: }).and_return []
          expect(alt_name_repository).to receive(:search_by_number).with({ jurisdiction_code: 'ca',
                                                                           company_number: }).and_return []
        end
        # rubocop:enable RSpec/ExpectInHook

        it 'returns resolved record' do
          result = subject.resolve(resolver_request)

          expect(result).to be_a RegisterSourcesOc::ResolverResponse
          expect(result.jurisdiction_code).to eq 'ca'
          expect(result.reconciliation_response).to be_nil
          expect(result.resolved).to be true
          expect(result.company).to eq company
          expect(result.add_ids).to eq []
          expect(result.alt_names).to eq []
        end
      end

      context 'with country not matching a jurisdiction code' do
        # rubocop:disable RSpec/ExpectInHook
        before do
          expect(company_service).not_to receive(:get_company)
          expect(jurisdiction_code_service).to receive(:query_jurisdiction).with(country, region: nil).and_return nil
        end
        # rubocop:enable RSpec/ExpectInHook

        it 'retuns response with reconciled false' do
          result = subject.resolve(resolver_request)

          expect(result).to be_a RegisterSourcesOc::ResolverResponse
          expect(result.jurisdiction_code).to be_nil
          expect(result.reconciliation_response).to be_nil
          expect(result.resolved).to be false
          expect(result.company).to be_nil
          expect(result.add_ids).to be_nil
          expect(result.alt_names).to be_nil
        end
      end

      context 'with country and region' do
        let(:region) { 'region' }

        # rubocop:disable RSpec/ExpectInHook
        before do
          expect(jurisdiction_code_service).to receive(:query_jurisdiction).with(country, region:).and_return 'ca'
          expect(company_service).to receive(:get_company).and_return company
          expect(add_id_repository).to receive(:search_by_number).with({ jurisdiction_code: 'ca',
                                                                         company_number: }).and_return []
          expect(alt_name_repository).to receive(:search_by_number).with({ jurisdiction_code: 'ca',
                                                                           company_number: }).and_return []
        end
        # rubocop:enable RSpec/ExpectInHook

        it 'retuns response with reconciled false' do
          result = subject.resolve(resolver_request)

          expect(result).to be_a RegisterSourcesOc::ResolverResponse
          expect(result.jurisdiction_code).to eq 'ca'
          expect(result.reconciliation_response).to be_nil
          expect(result.resolved).to be true
          expect(result.company).to eq company
          expect(result.add_ids).to eq []
          expect(result.alt_names).to eq []
        end
      end
    end

    context 'when company_number missing' do
      let(:company_number) { nil }

      context 'without reconcilation_response' do
        # rubocop:disable RSpec/ExpectInHook
        before do
          expect(reconciliation_service).to receive(:reconcile).with(
            RegisterSourcesOc::ReconciliationRequest.new(
              jurisdiction_code:,
              name:
            )
          ).and_return double('reconcilation_response', reconciled: false)
        end
        # rubocop:enable RSpec/ExpectInHook

        it 'returns unresolved record' do
          result = subject.resolve(resolver_request)

          expect(result).to be_a RegisterSourcesOc::ResolverResponse
          expect(result.reconciliation_response).to be_nil
          expect(result.resolved).to be false
          expect(result.company).to be_nil
          expect(result.add_ids).to be_nil
          expect(result.alt_names).to be_nil
        end
      end

      context 'with reconcilation_response' do
        let(:reconciled_company_number) { '901233' }

        # rubocop:disable RSpec/ExpectInHook
        before do
          expect(reconciliation_service).to receive(:reconcile).with(
            RegisterSourcesOc::ReconciliationRequest.new(
              jurisdiction_code:,
              name:
            )
          ).and_return RegisterSourcesOc::ReconciliationResponse.new(
            jurisdiction_code:,
            company_number: reconciled_company_number,
            name:,
            reconciled: true
          )

          expect(company_service).to receive(:get_company).and_return company
          expect(add_id_repository).to receive(:search_by_number).with({ jurisdiction_code:,
                                                                         company_number: '901233' }).and_return []
          expect(alt_name_repository).to receive(:search_by_number).with({ jurisdiction_code:,
                                                                           company_number: '901233' }).and_return []
        end
        # rubocop:enable RSpec/ExpectInHook

        it 'uses reconciled company_number' do
          result = subject.resolve(resolver_request)

          expect(result).to be_a RegisterSourcesOc::ResolverResponse
          expect(result.reconciliation_response.reconciled).to be true
          expect(result.reconciliation_response.company_number).to eq reconciled_company_number
          expect(result.resolved).to be true
          expect(result.company).to eq company
          expect(result.add_ids).to eq []
          expect(result.alt_names).to eq []
        end
      end
    end

    context 'when get_company returns a company' do
      # rubocop:disable RSpec/ExpectInHook
      before do
        expect(reconciliation_service).not_to receive(:reconcile)
        expect(company_service).to receive(:get_company).and_return company
        expect(add_id_repository).to receive(:search_by_number).with({ jurisdiction_code:,
                                                                       company_number: }).and_return []
        expect(alt_name_repository).to receive(:search_by_number).with({ jurisdiction_code:,
                                                                         company_number: }).and_return []
      end
      # rubocop:enable RSpec/ExpectInHook

      it 'returns resolved record' do
        result = subject.resolve(resolver_request)

        expect(result).to be_a RegisterSourcesOc::ResolverResponse
        expect(result.reconciliation_response).to be_nil
        expect(result.resolved).to be true
        expect(result.company).to eq company
        expect(result.add_ids).to eq []
        expect(result.alt_names).to eq []
      end
    end

    context 'when get_company does not return a company' do
      # rubocop:disable RSpec/ExpectInHook
      before do
        expect(reconciliation_service).not_to receive(:reconcile)
        expect(company_service).to receive(:get_company).and_return nil
      end
      # rubocop:enable RSpec/ExpectInHook

      context 'with search_companies returning an empty list of companies' do
        # rubocop:disable RSpec/ExpectInHook
        before do
          expect(company_service).to receive(:search_companies).and_return []
          expect(add_id_repository).to receive(:search_by_number).with({ jurisdiction_code:,
                                                                         company_number: }).and_return []
          expect(alt_name_repository).to receive(:search_by_number).with({ jurisdiction_code:,
                                                                           company_number: }).and_return []
        end
        # rubocop:enable RSpec/ExpectInHook

        it 'returns resolved record' do
          result = subject.resolve(resolver_request)

          expect(result).to be_a RegisterSourcesOc::ResolverResponse
          expect(result.reconciliation_response).to be_nil
          expect(result.resolved).to be false
          expect(result.company).to be_nil
          expect(result.add_ids).to eq []
          expect(result.alt_names).to eq []
        end
      end

      context 'with search_companies returning a non-empty list of companies' do
        # rubocop:disable RSpec/ExpectInHook
        before do
          expect(company_service).to receive(:search_companies).and_return [{ company: }]
          expect(add_id_repository).to receive(:search_by_number).with({ jurisdiction_code:,
                                                                         company_number: }).and_return []
          expect(alt_name_repository).to receive(:search_by_number).with({ jurisdiction_code:,
                                                                           company_number: }).and_return []
        end
        # rubocop:enable RSpec/ExpectInHook

        it 'returns resolved record' do
          result = subject.resolve(resolver_request)

          expect(result).to be_a RegisterSourcesOc::ResolverResponse
          expect(result.reconciliation_response).to be_nil
          expect(result.resolved).to be true
          expect(result.company).to eq company
          expect(result.add_ids).to eq []
          expect(result.alt_names).to eq []
        end
      end
    end

    context 'when get_company returns a company with add_ids' do
      # rubocop:disable RSpec/ExpectInHook
      before do
        expect(reconciliation_service).not_to receive(:reconcile)
        expect(company_service).to receive(:get_company).and_return company
        expect(add_id_repository).to receive(:search_by_number)
          .with({ jurisdiction_code:, company_number: })
          .and_return(add_ids.map { |e| RegisterSourcesOc::Repositories::AddIdRepository::SearchResult.new(e) })
        expect(alt_name_repository).to receive(:search_by_number)
          .with({ jurisdiction_code:, company_number: })
          .and_return(alt_names.map { |e| RegisterSourcesOc::Repositories::AltNameRepository::SearchResult.new(e) })
      end
      # rubocop:enable RSpec/ExpectInHook

      it 'returns resolved record' do
        result = subject.resolve(resolver_request)
        expect(result).to be_a RegisterSourcesOc::ResolverResponse
        expect(result.reconciliation_response).to be_nil
        expect(result.resolved).to be true
        expect(result.company).to eq company
        expect(result.add_ids).to eq add_ids
        expect(result.alt_names).to eq alt_names
      end
    end
  end
end
