require 'register_sources_oc/repositories/alt_name_repository'

RSpec.describe RegisterSourcesOc::Repositories::AltNameRepository do
  subject { described_class.new(client: es_client, index: index) }

  let(:es_client) { double 'es_client' }
  let(:index) { double 'index' }
  let(:fake_record_struct) { Struct.new(:jurisdiction_code, :company_number, :something) }

  describe '#search_by_number' do
    let(:jurisdiction_code) { 'gb' }
    let(:company_number) { 123456 }

    let(:hits) { [] }
    let(:results) { { 'hits' => { 'hits' => hits } } }

    let(:query_body) {
      {
        query: {
          bool: {
            must: [
              { match: { company_number: { query: 123456 }}},
              { match: { jurisdiction_code: { query: "gb" }}}
            ]
          }
        }
      }
    }

    before do
      expect(es_client).to receive(:search).with(
        index: index,
        body: query_body
      ).and_return results
    end

    context 'when has results' do
      let(:hits) do
        [
          {
            '_source' => {
              company_number: '123456',
              jurisdiction_code: 'gb',
              name: 'name',
              type: 'type',
              start_date: '2020-07-06',
              end_date: '2021-02-27',
            },
            '_score' => 4.5
          }
        ]
      end

      it 'searches elasticsearch' do
        results = subject.search_by_number(
          jurisdiction_code: jurisdiction_code,
          company_number: company_number
        )

        expect(results.length).to eq 1
        result = results.first
        record = result.record
        expect(record).to be_a RegisterSourcesOc::AltName

        expect(record.company_number).to eq '123456'
        expect(record.jurisdiction_code).to eq 'gb'
        expect(record.name).to eq 'name'
        expect(record.type).to eq 'type'
        expect(record.start_date).to eq '2020-07-06'
        expect(record.end_date).to eq '2021-02-27'

        expect(result.score).to eq 4.5
      end
    end

    context 'when has empty results' do
      let(:hits) { [] }

      it 'searches elasticsearch and returns empty results' do
        results = subject.search_by_number(
          jurisdiction_code: jurisdiction_code,
          company_number: company_number
        )

        expect(results).to eq []
      end
    end
  end

  describe '#store' do
    let(:records) do
      [
        fake_record_struct.new('gb1', 12345, 's1'),
        fake_record_struct.new('gb2', 12346, 's2'),
      ]
    end

    it 'calls bulk method for es_client' do
      allow(es_client).to receive(:bulk).and_return('errors' => nil)

      subject.store records

      expect(es_client).to have_received(:bulk).with(
        body: [
          {
            index: {
              _id: "gb1:12345:EMZsjw5KCNXDM3AyiNg2tKnVMPx38Yaa",
              _index: index,
              data: {
                company_number: 12345,
                jurisdiction_code: "gb1",
                something: 's1'
              }
            }
          },
          {
            index: {
              _id: "gb2:12346:S9tVgUGFPq4KPo7UrcYPVZ/wa2LqcsGQ",
              _index: index,
              data: {
                company_number: 12346,
                jurisdiction_code: "gb2",
                something: 's2'
              }
            }
          }
        ]
      )
    end
  end
end
