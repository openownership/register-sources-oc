# frozen_string_literal: true

require 'register_sources_oc/services/jurisdiction_code_service'

RSpec.describe RegisterSourcesOc::Services::JurisdictionCodeService do
  subject { described_class.new(geocoder_client:, open_corporate_client:) }

  let(:open_corporate_client) { double 'open_corporate_client' }
  let(:country) { 'CA' }
  let(:region) { 'Prince Edward Island C1' }
  let(:geocoder_client) { double 'geocoder_client' }

  before do
    allow(open_corporate_client).to receive(:get_jurisdiction_code)
    allow(geocoder_client).to receive(:jurisdiction)
  end

  describe '#query_jurisdiction' do
    context 'when region blank' do
      let(:region) { nil }

      it 'resolves using country' do
        expect(geocoder_client).to receive(:jurisdiction).with('CA').and_return double(
          state: nil,
          country: 'Canada'
        )
        expect(open_corporate_client).to receive(:get_jurisdiction_code).with('Canada').and_return 'ca'

        jurisdiction_code = subject.query_jurisdiction(country, region:)

        expect(jurisdiction_code).to eq 'ca'
      end
    end

    context 'when region provided' do
      context 'with state in geocoder response' do
        it 'uses country and state to obtain jurisdiction code' do
          expect(geocoder_client).to receive(:jurisdiction).with('Prince Edward Island C1, CA').and_return double(
            state: 'Prince Edward Island',
            country: 'Canada'
          )
          expect(open_corporate_client).to receive(:get_jurisdiction_code)
            .with('Prince Edward Island').and_return 'ca_pe'

          jurisdiction_code = subject.query_jurisdiction(country, region:)

          expect(jurisdiction_code).to eq 'ca_pe'
        end
      end

      context 'without state in geocoder response' do
        it 'uses country to obtain jurisdiction code' do
          expect(geocoder_client).to receive(:jurisdiction).with('Prince Edward Island C1, CA').and_return double(
            state: nil,
            country: 'Canada'
          )
          expect(open_corporate_client).to receive(:get_jurisdiction_code).with('Canada').and_return 'ca'

          jurisdiction_code = subject.query_jurisdiction(country, region:)

          expect(jurisdiction_code).to eq 'ca'
        end
      end

      context 'without state or country in geocoder response' do
        it 'uses country to obtain jurisdiction code' do
          expect(geocoder_client).to receive(:jurisdiction).with('Prince Edward Island C1, CA').and_return double(
            state: nil,
            country: nil
          )
          expect(open_corporate_client).to receive(:get_jurisdiction_code).with('CA').and_return 'ca'

          jurisdiction_code = subject.query_jurisdiction(country, region:)

          expect(jurisdiction_code).to eq 'ca'
        end
      end

      context 'without geocoder response' do
        it 'uses country to obtain jurisdiction code' do
          expect(geocoder_client).to receive(:jurisdiction).with('Prince Edward Island C1, CA').and_return nil
          expect(open_corporate_client).to receive(:get_jurisdiction_code).with('CA').and_return 'ca'

          jurisdiction_code = subject.query_jurisdiction(country, region:)

          expect(jurisdiction_code).to eq 'ca'
        end
      end
    end

    context 'when calling with the same arguments twice' do
      it 'uses the cache instead of calling geocoder and opencorporates twice' do
        allow(geocoder_client).to receive(:jurisdiction).with('Prince Edward Island C1, CA').and_return double(
          state: 'Prince Edward Island',
          country: 'Canada'
        )
        allow(open_corporate_client).to receive(:get_jurisdiction_code).with('Prince Edward Island').and_return 'ca_pe'

        jurisdiction_code = subject.query_jurisdiction(country, region:)
        expect(jurisdiction_code).to eq 'ca_pe'

        # calling again should not be calling anything
        jurisdiction_code_again = subject.query_jurisdiction(country, region:)
        expect(jurisdiction_code_again).to eq 'ca_pe'

        expect(geocoder_client).to have_received(:jurisdiction).once
        expect(open_corporate_client).to have_received(:get_jurisdiction_code).once
      end
    end
  end
end
