require 'spec_helper'
require 'et_ccd_client'
RSpec.describe EtCcdClient::Client do
  let(:mock_idam_client) { instance_spy(EtCcdClient::IdamClient, service_token: 'mockservicetoken') }
  let(:mock_config) { instance_double(EtCcdClient::Config, mock_config_values) }
  let(:mock_config_values) do
    {
      auth_base_url: 'http://auth.mock.com',
      idam_base_url: 'http://idam.mock.com',
      data_store_base_url: 'http://data.mock.com',
      jurisdiction_id: 'mockjid',
      microservice: 'mockmicroservice',
      logger: mock_logger,
      user_id: 51,
      initiate_claim_event_id: 'mockinitiateevent',
      initiate_case_url: 'http://data.mock.com/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/event-triggers/{etid}/token',
      create_case_url: 'http://data.mock.com/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/cases'
    }
  end
  let(:mock_logger) do
    instance_spy('ActiveSupport::Logger').tap do |spy|
      allow(spy).to receive(:tagged) do |_arg1, &block|
        block.call
      end
    end
  end
  subject(:client) { described_class.new(idam_client: mock_idam_client, config: mock_config) }
  let(:default_response_headers) { { 'Content-Type' => 'application/json' } }

  describe "#login" do
    it "delegates to the idam client with default values" do
      # Act - Call with no arguments
      client.login

      # Assert - Ensure it calls login in idam client with no arguments
      expect(mock_idam_client).to have_received(:login).with(no_args)
    end
    it "delegates to the idam client with specified user_id" do
      # Act - Call with user_id
      client.login(user_id: 19)

      # Assert - Ensure it calls login in idam client with no arguments
      expect(mock_idam_client).to have_received(:login).with(user_id: 19)
    end
    it "delegates to the idam client with specified role" do
      # Act - Call with user_id
      client.login(role: 'testrole')

      # Assert - Ensure it calls login in idam client with no arguments
      expect(mock_idam_client).to have_received(:login).with(role: 'testrole')
    end

  end

  describe "#caseworker_start_case_creation" do
    it "performs the correct http request" do
      # Arrange - stub the url
      stub = stub_request(:get, "http://data.mock.com/caseworkers/51/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiateevent/token").
        to_return(body: '{}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_start_case_creation(case_type_id: 'mycasetypeid')

      # Assert
      expect(stub).to have_been_requested
    end

    it "returns the correct hash from the json" do
      # Arrange - stub the url
      stub_request(:get, "http://data.mock.com/caseworkers/51/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiateevent/token").
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      result = client.caseworker_start_case_creation(case_type_id: 'mycasetypeid')

      # Assert
      expect(result).to eq("test" => "value")
    end

    it "uses a tagged logger" do
      # Arrange - stub the url
      stub_request(:get, "http://data.mock.com/caseworkers/51/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiateevent/token").
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_start_case_creation(case_type_id: 'mycasetypeid')

      # Assert
      expect(mock_logger).to have_received(:tagged)
    end

    it "logs the request" do
      # Arrange - stub the url
      url = "http://data.mock.com/caseworkers/51/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiateevent/token"
      stub_request(:get, "#{url}").
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_start_case_creation(case_type_id: 'mycasetypeid')

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET > Start case creation (#{url})")
    end

    it "logs the response" do
      # Arrange - stub the url
      resp_body = '{"test":"value"}'
      stub_request(:get, "http://data.mock.com/caseworkers/51/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiateevent/token").
        to_return(body: resp_body, headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_start_case_creation(case_type_id: 'mycasetypeid')

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET < Start case creation - #{resp_body}")
    end

    it "logs the response under error conditions" do
      # Arrange - stub the url
      resp_body = '{"message": "Not found"}'
      stub_request(:get, "http://data.mock.com/caseworkers/51/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiateevent/token").
        to_return(body: resp_body, headers: default_response_headers, status: 404)

      # Act - Call the method
      client.caseworker_start_case_creation(case_type_id: 'mycasetypeid') rescue RestClient::NotFound

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET < Start case creation (ERROR) - #{resp_body}")
    end
  end

  describe "#caseworker_case_create" do
    it "performs the correct http request" do
      # Arrange - stub the url
      stub = stub_request(:post, "http://data.mock.com/caseworkers/51/jurisdictions/mockjid/case-types/mycasetypeid/cases").
        with(headers: {"Content-Type": "application/json"}).
        to_return(body: '{}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_case_create({}, case_type_id: 'mycasetypeid')

      # Assert
      expect(stub).to have_been_requested
    end

    it "returns the correct json" do
      # Arrange - stub the url
      stub_request(:post, "http://data.mock.com/caseworkers/51/jurisdictions/mockjid/case-types/mycasetypeid/cases").
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      result = client.caseworker_case_create({}, case_type_id: 'mycasetypeid')

      # Assert
      expect(result).to eql("test" => "value")
    end

    it "uses a tagged logger" do
      # Arrange - stub the url
      stub_request(:post, "http://data.mock.com/caseworkers/51/jurisdictions/mockjid/case-types/mycasetypeid/cases").
        to_return(body: '{}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_case_create({}, case_type_id: 'mycasetypeid')

      # Assert
      expect(mock_logger).to have_received(:tagged)
    end

    it "logs the request" do
      # Arrange - stub the url
      url = "http://data.mock.com/caseworkers/51/jurisdictions/mockjid/case-types/mycasetypeid/cases"
      stub_request(:post, url).
        to_return(body: '{}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_case_create({test: :data}, case_type_id: 'mycasetypeid')

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET > Caseworker create case (#{url}) - {\"test\":\"data\"}")
    end

    it "logs the response" do
      # Arrange - stub the url
      resp_body = '{"test":"value"}'
      stub_request(:post, "http://data.mock.com/caseworkers/51/jurisdictions/mockjid/case-types/mycasetypeid/cases").
        to_return(body: resp_body, headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_case_create({}, case_type_id: 'mycasetypeid')

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET < Case worker create case - #{resp_body}")
    end

    it "logs the response under error conditions" do
      # Arrange - stub the url
      resp_body = '{"message": "Not found"}'
      stub_request(:post, "http://data.mock.com/caseworkers/51/jurisdictions/mockjid/case-types/mycasetypeid/cases").
        to_return(body: resp_body, headers: default_response_headers, status: 422)

      # Act - Call the method
      client.caseworker_case_create({}, case_type_id: 'mycasetypeid') rescue RestClient::UnprocessableEntity

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET < Case worker create case (ERROR) - #{resp_body}")
    end
  end

  describe "#caseworker_search_by_reference" do

  end
  describe "#caseworker_search_latest_by_reference" do

  end

  describe "#caseworker_cases_pagination_metadata" do

  end
end
