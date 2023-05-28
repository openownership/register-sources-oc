require 'register_sources_oc/structs/alt_name'

RSpec.describe RegisterSourcesOc::AltName do
  subject { described_class }

  context 'when given valid data' do
    let(:input_data) do
      {
        company_number: '123456',
        jurisdiction_code: 'gb',
        name: 'name',
        type: 'type',
        start_date: '2020-07-06',
        end_date: '2021-02-27',
      }
    end

    it 'maps to struct correctly' do
      obj = described_class.new(input_data)

      expect(obj.company_number).to eq '123456'
      expect(obj.jurisdiction_code).to eq 'gb'
      expect(obj.name).to eq 'name'
      expect(obj.type).to eq 'type'
      expect(obj.start_date).to eq '2020-07-06'
      expect(obj.end_date).to eq '2021-02-27'
    end
  end
end
