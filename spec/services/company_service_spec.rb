require 'register_sources_oc/services/company_service'

RSpec.shared_examples "trying services examples" do |method, args|
  context 'when neither service has a result' do
    it 'returns nil' do
      expect(service1).to receive(method).with(*args).and_return nil
      expect(service2).to receive(method).with(*args).and_return nil

      result = subject.send(method, *args)
      expect(result).to be_nil
    end
  end

  context 'when first service has a result' do
    it 'returns result' do
      expected = double 'result'
      expect(service1).to receive(method).with(*args).and_return expected
      expect(service2).not_to receive(method)

      result = subject.send(method, *args)
      expect(result).to eq expected
    end
  end

  context 'when first service has no result but second service has a result' do
    it 'returns result' do
      expected = double 'result'
      expect(service1).to receive(method).with(*args).and_return nil
      expect(service2).to receive(method).with(*args).and_return expected

      result = subject.send(method, *args)
      expect(result).to eq expected
    end
  end
end

RSpec.describe RegisterSourcesOc::Services::CompanyService do
  subject do
    described_class.new(
      services: [
        { name: 'service1', service: service1 },
        { name: 'service2', service: service2 }
      ],
      verbose: false
    )
  end

  let(:service1) { double 'service1' }
  let(:service2) { double 'service2' }

  describe '#get_jurisdiction_code' do
    include_examples "trying services examples",
      :get_jurisdiction_code, :args
  end

  describe '#get_company' do
    include_examples "trying services examples",
      :get_company, ['jurisdiction_code', 'company_number', { sparse: true }]
  end

  describe '#search_companies' do
    include_examples "trying services examples",
      :search_companies, ['jurisdiction_code', 'company_number']
  end

  describe '#search_companies_by_name' do
    include_examples "trying services examples",
      :search_companies_by_name, ['name']
  end
end
