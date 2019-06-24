require 'spec_helper'
require 'et_ccd_client'
RSpec.describe EtCcdClient::Client do
  let(:mock_idam_client) { instance_spy(EtCcdClient::IdamClient, service_token: 'mockservicetoken', login: nil) }
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
        with(headers: {"Content-Type": "application/x-www-form-urlencoded"}).
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
      resp_body = {
          "exception": "uk.gov.hmcts.ccd.endpoint.exceptions.CaseValidationException",
          "timestamp": "2019-06-23T17:13:07.282",
          "status": 422,
          "error": "Unprocessable Entity",
          "message": "Case data validation failed",
          "path": "/caseworkers/22/jurisdictions/EMPLOYMENT/case-types/EmpTrib_MVP_1.0_Manc/cases",
          "details": {
              "field_errors": [
                  {
                      "id": "claimantType.claimant_addressUK.PostCode",
                      "message": "1065^&%$£@():?><*& exceed maximum length 14"
                  }
              ]
          }
      }.to_json
      stub_request(:post, "http://data.mock.com/caseworkers/51/jurisdictions/mockjid/case-types/mycasetypeid/cases").
        to_return(body: resp_body, headers: default_response_headers, status: 422)

      # Act - Call the method
      client.caseworker_case_create({}, case_type_id: 'mycasetypeid') rescue EtCcdClient::Exceptions::UnprocessableEntity

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET < Case worker create case (ERROR) - #{resp_body}")
    end

    it "re raises the response with the response body available under error conditions with detailed message" do
      # Arrange - stub the url
      resp_body = {
          "exception": "uk.gov.hmcts.ccd.endpoint.exceptions.CaseValidationException",
          "timestamp": "2019-06-23T17:13:07.282",
          "status": 422,
          "error": "Unprocessable Entity",
          "message": "Case data validation failed",
          "path": "/caseworkers/22/jurisdictions/EMPLOYMENT/case-types/EmpTrib_MVP_1.0_Manc/cases",
          "details": {
              "field_errors": [
                  {
                      "id": "claimantType.claimant_addressUK.PostCode",
                      "message": "1065^&%$£@():?><*& exceed maximum length 14"
                  }
              ]
          }
      }.to_json
      stub_request(:post, "http://data.mock.com/caseworkers/51/jurisdictions/mockjid/case-types/mycasetypeid/cases").
        to_return(body: resp_body, headers: default_response_headers, status: 422)

      # Act - Call the method
      case_create = -> { client.caseworker_case_create({}, case_type_id: 'mycasetypeid') }
      expect(case_create).to raise_error(EtCcdClient::Exceptions::UnprocessableEntity) do |error|
        expect(error.message).to include("claimantType.claimant_addressUK.PostCode => 1065^&%$£@():?><*& exceed maximum length 14")
      end

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET < Case worker create case (ERROR) - #{resp_body}")
    end

    it "re raises the response with the response body available under error conditions with standard message" do
      # Arrange - stub the url
      resp_body = "Unauthorized"
      stub_request(:post, "http://data.mock.com/caseworkers/51/jurisdictions/mockjid/case-types/mycasetypeid/cases").
        to_return(body: resp_body, headers: default_response_headers, status: 401)

      # Act - Call the method
      case_create = -> { client.caseworker_case_create({}, case_type_id: 'mycasetypeid') }
      expect(case_create).to raise_error(EtCcdClient::Exceptions::Base) do |error|
        expect(error.message).to include("Unauthorized")
      end

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
