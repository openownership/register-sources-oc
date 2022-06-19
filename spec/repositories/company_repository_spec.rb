require 'register_sources_oc/repositories/company_repository'

RSpec.describe RegisterSourcesOc::Repositories::CompanyRepository do
  subject { described_class.new(client: es_client, index: index) }

  let(:es_client) { double 'es_client' }
  let(:index) { double 'index' }
  let(:fake_record_struct) { Struct.new(:jurisdiction_code, :company_number, :something) }

  describe '#get' do
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
              company_type: 'company_type',
              incorporation_date: '1234',
              dissolution_date: '5678',
              restricted_for_marketing: 'false',
              registered_address_in_full: 'registered_in_full'
            },
            '_score' => 4.5
          }
        ]
      end

      it 'searches elasticsearch' do
        results = subject.get(jurisdiction_code: jurisdiction_code, company_number: company_number)

        expect(results.length).to eq 1
        result = results.first
        record = result.record
        expect(record).to be_a RegisterSourcesOc::Company

        expect(record.company_number).to eq '123456'
        expect(record.jurisdiction_code).to eq 'gb'
        expect(record.name).to eq 'name'
        expect(record.company_type).to eq 'company_type'
        expect(record.incorporation_date).to eq '1234'
        expect(record.dissolution_date).to eq '5678'
        expect(record.restricted_for_marketing).to eq 'false'
        expect(record.registered_address_in_full).to eq 'registered_in_full'

        expect(result.score).to eq 4.5
      end
    end
  
    context 'when has empty results' do
      let(:hits) { [] }

      it 'searches elasticsearch and returns empty results' do
        results = subject.get(jurisdiction_code: jurisdiction_code, company_number: company_number)

        expect(results).to eq []
      end
    end
  end

  describe '#search_by_number' do
    
  end

  describe '#search_by_name' do
    
  end

  describe '#store' do
    let(:records) do
      [
        fake_record_struct.new('gb1', 12345, 's1'),
        fake_record_struct.new('gb2', 12346, 's2'),
      ]
    end

    it 'calls bulk method for es_client' do
      allow(es_client).to receive(:bulk)

      subject.store records

      expect(es_client).to have_received(:bulk).with(
        body: [
          {
            index: {
              _id: "gb1:12345",
              _index: index,
              _type: "company",
              data: {
                company_number: 12345,
                jurisdiction_code: "gb1",
                something: 's1'
              }
            }
          },
          {
            index: {
              _id: "gb2:12346",
              _index: index,
              _type: "company",
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
