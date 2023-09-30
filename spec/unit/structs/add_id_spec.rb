# frozen_string_literal: true

require 'register_sources_oc/structs/add_id'

RSpec.describe RegisterSourcesOc::AddId do
  subject { described_class }

  context 'when given valid data' do
    let(:input_data) do
      {
        company_number: '123456',
        jurisdiction_code: 'gb',
        uid: 'uid',
        identifier_system_code: 'identifier_system_code'
      }
    end

    it 'maps to struct correctly' do
      obj = described_class.new(input_data)

      expect(obj.company_number).to eq '123456'
      expect(obj.jurisdiction_code).to eq 'gb'
      expect(obj.uid).to eq 'uid'
      expect(obj.identifier_system_code).to eq 'identifier_system_code'
    end
  end
end
