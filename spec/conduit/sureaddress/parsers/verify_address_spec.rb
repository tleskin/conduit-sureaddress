require 'spec_helper'

describe Conduit::Driver::Sureaddress::VerifyAddress::Parser do
  subject             { described_class.new(response_body, status) }
  let(:response_body) { mocker.send(:render_response) }
  let(:mock_status)   { :success }
  let(:status)        { 200 }
  let(:mocker) do
    Conduit::Sureaddress::RequestMocker::VerifyAddress.new(base,
      mock_status: mock_status)
  end
  let(:base) do
    instance_double(Conduit::Driver::Sureaddress::VerifyAddress,
      view_context: view_context)
  end
  let(:view_context) do
    OpenStruct.new(primary_address_line:   '207 S. Staghorn Lane',
                   secondary_address_line: '',
                   city:                   'Greer',
                   state:                  'SC',
                   zip_code:               29650,
                   response_type:          'S',
                   match_count:            1
                  )
  end

  context 'with a success body' do
    its(:response_status) { should eql 'success' }
    its(:response_errors) { should be_nil }

    its(:score)           { should eql 1 }
    its(:zip_plus_4)      { should eql '4065' }
    its(:latitude)        { should_not be_zero }
    its(:longitude)       { should_not be_zero }
    its(:time_zone)       { should_not be_zero }
    its(:geocode)         { should_not be_empty }
    its(:daylight_saving?)      { should eql true }
    its(:match_limit_exceeded?) { should eql true }
    its(:top_match_unique?)     { should eql true }
  end

  context 'with a low-confidence success body' do
    let(:mock_status)     { :low_confidence }

    its(:response_status) { should eql 'success' }
    its(:response_errors) { should be_nil }

    its(:score)           { should eql 0.54 }
    its(:zip_plus_4)      { should eql '4065' }
    its(:latitude)        { should_not be_zero }
    its(:longitude)       { should_not be_zero }
    its(:time_zone)       { should_not be_zero }
    its(:geocode)         { should_not be_empty }
    its(:daylight_saving?)      { should eql true }
    its(:match_limit_exceeded?) { should eql true }
    its(:top_match_unique?)     { should eql true }
  end

  context 'with failure for no matching address' do
    let(:mock_status)     { :failure }

    its(:response_status) { should eql 'failure' }
    its(:response_errors) { should eql({error: 'No match found'}) }

    its(:score)           { should eql 0 }
    its(:zip_plus_4)      { should be_empty }
    its(:latitude)        { should be_zero }
    its(:longitude)       { should be_zero }
    its(:time_zone)       { should be_zero }
    its(:geocode)         { should be_empty }
    its(:daylight_saving?)      { should eql false }
    its(:match_limit_exceeded?) { should eql false }
    its(:top_match_unique?)     { should eql false }
  end

  context 'with error' do
    let(:mock_status)     { :error }
    let(:status)          { 500 }

    its(:response_status) { should eql 'error' }
    its(:response_errors) { should eql({error: 'Unexpected response from server.'}) }
  end
end
