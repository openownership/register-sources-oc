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

  context 'when comparison_mode true and both services have a result' do
    let(:comparison_mode) { true }

    context 'with both results matching' do
      it 'returns result' do
        expected = double 'result'
        comparer_response = double 'comparer_response'
        expect(service1).to receive(method).with(*args).and_return expected
        expect(service2).to receive(method).with(*args).and_return expected
        expect(comparer).to receive(:compare_results).with(
          'service1' => expected,
          'service2' => expected
        ).and_return comparer_response

        result = subject.send(method, *args)
        expect(result).to eq comparer_response
      end
    end

    context 'with neither results matching' do
      it 'returns result' do
        expected = double 'result'
        expected2 = double 'result2'
        comparer_response = double 'comparer_response'
        expect(service1).to receive(method).with(*args).and_return expected
        expect(service2).to receive(method).with(*args).and_return expected2
        expect(comparer).to receive(:compare_results).with(
          'service1' => expected,
          'service2' => expected2
        ).and_return comparer_response

        result = subject.send(method, *args)
        expect(result).to eq comparer_response
      end
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
      verbose: false,
      comparison_mode: comparison_mode,
      comparer: comparer
    )
  end

  let(:service1) { double 'service1' }
  let(:service2) { double 'service2' }
  let(:comparer) { double 'comparer' }
  let(:comparison_mode) { false }

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
