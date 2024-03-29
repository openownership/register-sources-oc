# frozen_string_literal: true

require 'register_sources_oc/repository'
require 'register_sources_oc/structs/add_id'

RSpec.describe RegisterSourcesOc::Repository do
  subject { described_class.new(RegisterSourcesOc::AddId, client: es_client, index:) }

  let(:es_client) { double 'es_client' }
  let(:index) { double 'index' }
  let(:fake_record_struct) { Struct.new(:jurisdiction_code, :company_number, :something) }

  describe '#search_by_number' do
    let(:jurisdiction_code) { 'gb' }
    let(:company_number) { '123456' }

    let(:hits) { [] }
    let(:results) { { 'hits' => { 'hits' => hits } } }

    let(:query_body) do
      {
        query: {
          bool: {
            must: [
              { match: { company_number: { query: '123456' } } },
              { match: { jurisdiction_code: { query: 'gb' } } }
            ]
          }
        }
      }
    end

    # rubocop:disable RSpec/ExpectInHook
    before do
      expect(es_client).to receive(:search).with(
        index:,
        body: query_body
      ).and_return results
    end
    # rubocop:enable RSpec/ExpectInHook

    context 'when has results' do
      let(:hits) do
        [
          {
            '_source' => {
              company_number: '123456',
              jurisdiction_code: 'gb',
              uid: 'uid',
              identifier_system_code: 'identifier_system_code'
            },
            '_score' => 4.5
          }
        ]
      end

      it 'searches elasticsearch' do
        results = subject.search_by_number(
          jurisdiction_code:,
          company_number:
        )

        expect(results.length).to eq 1
        result = results.first
        record = result.record
        expect(record).to be_a RegisterSourcesOc::AddId

        expect(record.company_number).to eq '123456'
        expect(record.jurisdiction_code).to eq 'gb'
        expect(record.uid).to eq 'uid'
        expect(record.identifier_system_code).to eq 'identifier_system_code'

        expect(result.score).to eq 4.5
      end
    end

    context 'when has empty results' do
      let(:hits) { [] }

      it 'searches elasticsearch and returns empty results' do
        results = subject.search_by_number(
          jurisdiction_code:,
          company_number:
        )

        expect(results).to eq []
      end
    end
  end

  describe '#store' do
    let(:records) do
      [
        fake_record_struct.new('gb1', 12_345, 's1'),
        fake_record_struct.new('gb2', 12_346, 's2')
      ]
    end

    it 'calls bulk method for es_client' do
      allow(es_client).to receive(:bulk).and_return('errors' => nil)

      subject.store records

      expect(es_client).to have_received(:bulk).with(
        body: [
          {
            index: {
              _id: 'gb1:12345:EMZsjw5KCNXDM3AyiNg2tKnVMPx38Yaa',
              _index: index,
              data: {
                company_number: 12_345,
                jurisdiction_code: 'gb1',
                something: 's1'
              }
            }
          },
          {
            index: {
              _id: 'gb2:12346:S9tVgUGFPq4KPo7UrcYPVZ/wa2LqcsGQ',
              _index: index,
              data: {
                company_number: 12_346,
                jurisdiction_code: 'gb2',
                something: 's2'
              }
            }
          }
        ]
      )
    end
  end
end
