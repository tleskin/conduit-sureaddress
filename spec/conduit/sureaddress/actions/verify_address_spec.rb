require 'spec_helper'

describe Conduit::Driver::Sureaddress::VerifyAddress do
  let(:verify_address) { described_class.new(address_attributes) }
  let(:address_attributes) do
    { client_number: 1, validation_key: 'abcd-1234', response_type: 'S',
      match_count: 1, primary_address_line: '123 Main St', state: 'FL',
      city: 'Palm Beach Gardens', zip_code: 33410 }
  end

  it 'should not raise an error with all required attributes' do
    expect { verify_address }.not_to raise_exception
  end

  context 'url methods' do
    subject { verify_address }

    its(:http_method) { should eql :post }
    its(:remote_url) do
      should eql 'https://testapi.sureaddress.net/SureAddress.asmx/PostRequest'
    end
  end

  context 'when response_type and match_count are omitted' do
    let(:address_attributes) do
      { client_number: 1, validation_key: 'abcd-1234', city: 'Palm Beach Gardens',
        primary_address_line: '123 Main St', state: 'FL', zip_code: 33410 }
    end

    it 'should not raise an error with all required attributes' do
      expect { verify_address }.not_to raise_exception
    end

    its('view_context.response_type') { should eql 'S' }
    its('view_context.match_count')   { should eql 1 }
  end

  context 'if host_override is provided' do
    subject { verify_address }

    let(:address_attributes) do
      { host_override: 'https://myaddress.sureaddress.net' }
    end
    its(:remote_url) do
      should eql 'https://myaddress.sureaddress.net/SureAddress.asmx/PostRequest'
    end
  end

  describe '#mock_mode?' do
    subject { verify_address }
    let(:address_attributes) { { mock_status: status } }

    context 'when mock_status is not provided' do
      let(:status) { nil }
      its(:mock_mode?) { should eql false }
    end

    context 'when mock_status is blank' do
      let(:status) { '' }
      its(:mock_mode?) { should eql false }
    end

    context 'when mock_status is not blank' do
      let(:status) { 'success' }
      its(:mock_mode?) { should eql true }
    end
  end

  describe '#perform_request' do
    subject { verify_address.perform.parser }
    let(:base_attributes) do
      { client_number: 1, validation_key: 'abcd-1234', response_type: 'S',
        match_count: 1, primary_address_line: '123 Main St', state: 'FL',
        city: 'Palm Beach Gardens', zip_code: 33410 }
    end

    context 'success response' do
      let(:address_attributes) { base_attributes.merge(mock_status: 'success') }
      its(:response_status) { should eql 'success' }
      its(:response_errors) { should be_nil }
      its(:score)           { should eql 1 }
    end

    context 'success response with low confidence' do
      let(:address_attributes) { base_attributes.merge(mock_status: 'low_confidence') }
      its(:response_status) { should eql 'success' }
      its(:response_errors) { should be_nil }
      its(:score)           { should eql 0.54 }
    end

    context 'failure response' do
      let(:address_attributes) { base_attributes.merge(mock_status: 'failure') }
      its(:response_status) { should eql 'failure' }
      its(:response_errors) { should eql({error: 'No match found'}) }
    end

    context 'error response' do
      let(:address_attributes) { base_attributes.merge(mock_status: 'error') }
      its(:response_status) { should eql 'error' }
      its(:response_errors) { should eql({error: 'Unexpected response from server.'}) }
    end
  end
end
