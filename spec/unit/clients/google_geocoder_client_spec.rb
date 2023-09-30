# frozen_string_literal: true

require 'register_sources_oc/clients/google_geocoder_client'

RSpec.describe RegisterSourcesOc::Clients::GoogleGeocoderClient do
  subject { described_class.new(api_key:, error_adapter:) }

  let(:api_key) { 'api_token_xxx' }
  let(:geocode_response) do
    double(state_name: 'Prince Edward Island', state_code: 'PE', country: 'Canada', country_code: 'CA', success?: true)
  end
  let(:address_string) { 'address' }
  let(:error_adapter) { nil }

  before do
    allow(Geokit::Geocoders::GoogleGeocoder).to receive(:api_key=).with(api_key)
    allow(Geokit::Geocoders::GoogleGeocoder).to receive(:geocode).and_return geocode_response
  end

  describe '#jurisdiction' do
    context 'when api_key is given' do
      context 'with result successful' do
        it 'returns geocode_response' do
          result = subject.jurisdiction address_string

          expect(result).to eq RegisterSourcesOc::GeocoderResponse.new(
            country: 'Canada',
            country_code: 'ca',
            state: 'Prince Edward Island',
            state_code: 'pe'
          )
        end
      end

      context 'with result unsuccessful' do
        let(:geocode_response) do
          double(state_name: 'Prince Edward Island', state_code: 'PE', country: 'Canada', country_code: 'CA',
                 success?: false)
        end

        it 'returns nil' do
          result = subject.jurisdiction address_string

          expect(result).to be_nil
        end
      end
    end

    context 'when api_key is nil' do
      let(:api_key) { nil }

      it 'returns nil without calling geocoder' do
        result = subject.jurisdiction address_string

        expect(result).to be_nil
        expect(Geokit::Geocoders::GoogleGeocoder).not_to have_received(:api_key=)
        expect(Geokit::Geocoders::GoogleGeocoder).not_to have_received(:geocode)
      end
    end

    context 'when raises an error' do
      let(:geocode_response) do
        # This should error since country_code is nil and will try downcase
        double(state_name: 'Prince Edward Island', state_code: 'PE', country: 'Canada', country_code: nil,
               success?: true)
      end

      context 'with error adapter nil' do
        it 'returns nil' do
          result = subject.jurisdiction address_string

          expect(result).to be_nil
        end
      end

      context 'with error adapter given' do
        let(:error_adapter) { double 'error_adapter' }

        it 'returns nil' do
          allow(error_adapter).to receive(:error)

          result = subject.jurisdiction address_string

          expect(result).to be_nil

          expect(error_adapter).to have_received(:error)
        end
      end
    end
  end
end
