require 'spec_helper'
require 'et_ccd_client'
require 'rack'


RSpec.describe EtCcdClient::Client do
  subject(:client) { described_class.new(idam_client: mock_idam_client, config: mock_config) }

  let(:mock_idam_client) { instance_spy(EtCcdClient::IdamClient, service_token: 'mockservicetoken', user_token: 'mockusertoken', user_details: { 'id' => 'mockuserid', 'roles' => ['mockrole1', 'mockrole2'] }, login: nil) }
  let(:mock_config) { instance_double(EtCcdClient::Config, mock_config_values) }
  let(:mock_config_values) do
    {
      auth_base_url: 'http://auth.mock.com',
      idam_base_url: 'http://idam.mock.com',
      data_store_base_url: 'http://data.mock.com',
      document_store_base_url: 'http://documents.mock.com',
      jurisdiction_id: 'mockjid',
      microservice: 'mockmicroservice',
      microservice_secret: 'nottellingyouitsasecret',
      logger: mock_logger,
      user_id: 51,
      initiate_claim_event_id: 'mockinitiateevent',
      initiate_bulk_event_id: 'mockinitiatebulkevent',
      initiate_case_url: 'http://data.mock.com/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/event-triggers/{etid}/token',
      create_case_url: 'http://data.mock.com/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/cases',
      upload_file_url: 'http://documents.mock.com/documents',
      use_sidam: true,
      sidam_username: 'm@m.com',
      sidam_password: 'p',
      verify_ssl: false
    }
  end
  let(:mock_logger) do
    instance_spy('ActiveSupport::Logger').tap do |spy|
      allow(spy).to receive(:tagged) do |_arg1, &block|
        block.call
      end
    end
  end
  let(:default_response_headers) { { 'Content-Type' => 'application/json' } }

  describe "#login" do
    context 'when using sidam' do
      it "delegates to the idam client with default values" do
        # Act - Call with no arguments
        client.login

        # Assert - Ensure it calls login in idam client with no arguments
        expect(mock_idam_client).to have_received(:login).with(no_args)
      end

      it "delegates to the idam client with specified user_id" do
        # Act - Call with user_id
        client.login(username: 'username')

        # Assert - Ensure it calls login in idam client with no arguments
        expect(mock_idam_client).to have_received(:login).with(username: 'username')
      end

      it "delegates to the idam client with specified role" do
        # Act - Call with user_id
        client.login(password: 'password')

        # Assert - Ensure it calls login in idam client with no arguments
        expect(mock_idam_client).to have_received(:login).with(password: 'password')
      end

    end

    context 'when using tidam' do
      let(:mock_config_values) do
        {
          auth_base_url: 'http://auth.mock.com',
          idam_base_url: 'http://idam.mock.com',
          data_store_base_url: 'http://data.mock.com',
          jurisdiction_id: 'mockjid',
          microservice: 'mockmicroservice',
          microservice_secret: 'nottellingyouitsasecret',
          logger: mock_logger,
          user_id: 51,
          initiate_claim_event_id: 'mockinitiateevent',
          initiate_case_url: 'http://data.mock.com/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/event-triggers/{etid}/token',
          create_case_url: 'http://data.mock.com/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/cases',
          use_sidam: false,
          verify_ssl: false
        }
      end
      let(:mock_idam_client) { instance_spy(EtCcdClient::TidamClient, service_token: 'mockservicetoken', login: nil) }

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

  end

  describe "#caseworker_start_case_creation" do
    it "performs the correct http request" do
      # Arrange - stub the url
      stub = stub_request(:get, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiateevent/token").
             to_return(body: '{}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_start_case_creation(case_type_id: 'mycasetypeid')

      # Assert
      expect(stub).to have_been_requested
    end

    it "returns the correct hash from the json" do
      # Arrange - stub the url
      stub_request(:get, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiateevent/token").
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      result = client.caseworker_start_case_creation(case_type_id: 'mycasetypeid')

      # Assert
      expect(result).to eq("test" => "value")
    end

    it "uses a tagged logger" do
      # Arrange - stub the url
      stub_request(:get, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiateevent/token").
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_start_case_creation(case_type_id: 'mycasetypeid')

      # Assert
      expect(mock_logger).to have_received(:tagged)
    end

    it "logs the request" do
      # Arrange - stub the url
      url = "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiateevent/token"
      stub_request(:get, url).
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_start_case_creation(case_type_id: 'mycasetypeid')

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET > Start case creation (#{url})")
    end

    it "logs the response" do
      # Arrange - stub the url
      resp_body = '{"test":"value"}'
      stub_request(:get, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiateevent/token").
        to_return(body: resp_body, headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_start_case_creation(case_type_id: 'mycasetypeid')

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET < Start case creation - #{resp_body}")
    end

    it "logs the response under error conditions" do
      # Arrange - stub the url
      resp_body = '{"message": "Not found"}'
      stub_request(:get, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiateevent/token").
        to_return(body: resp_body, headers: default_response_headers, status: 404)

      # Act - Call the method
      action = -> { client.caseworker_start_case_creation(case_type_id: 'mycasetypeid') }

      # Assert
      aggregate_failures "Both exception should be raised and log should be recorded" do
        expect(action).to raise_exception(EtCcdClient::Exceptions::Base)
        expect(mock_logger).to have_received(:debug).with("ET < Start case creation (ERROR) - #{resp_body}")
      end
    end
  end
  describe "#caseworker_start_bulk_creation" do
    it "performs the correct http request" do
      # Arrange - stub the url
      stub = stub_request(:get, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiatebulkevent/token").
             to_return(body: '{}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_start_bulk_creation(case_type_id: 'mycasetypeid')

      # Assert
      expect(stub).to have_been_requested
    end

    it "returns the correct hash from the json" do
      # Arrange - stub the url
      stub_request(:get, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiatebulkevent/token").
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      result = client.caseworker_start_bulk_creation(case_type_id: 'mycasetypeid')

      # Assert
      expect(result).to eq("test" => "value")
    end

    it "uses a tagged logger" do
      # Arrange - stub the url
      stub_request(:get, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiatebulkevent/token").
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_start_bulk_creation(case_type_id: 'mycasetypeid')

      # Assert
      expect(mock_logger).to have_received(:tagged)
    end

    it "logs the request" do
      # Arrange - stub the url
      url = "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiatebulkevent/token"
      stub_request(:get, url).
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_start_bulk_creation(case_type_id: 'mycasetypeid')

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET > Start bulk creation (#{url})")
    end

    it "logs the response" do
      # Arrange - stub the url
      resp_body = '{"test":"value"}'
      stub_request(:get, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiatebulkevent/token").
        to_return(body: resp_body, headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_start_bulk_creation(case_type_id: 'mycasetypeid')

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET < Start bulk creation - #{resp_body}")
    end

    it "logs the response under error conditions" do
      # Arrange - stub the url
      resp_body = '{"message": "Not found"}'
      stub_request(:get, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/event-triggers/mockinitiatebulkevent/token").
        to_return(body: resp_body, headers: default_response_headers, status: 404)

      # Act - Call the method
      action = -> { client.caseworker_start_bulk_creation(case_type_id: 'mycasetypeid') }

      # Assert
      aggregate_failures "Both exception should be raised and log should be recorded" do
        expect(action).to raise_exception(EtCcdClient::Exceptions::Base)
        expect(mock_logger).to have_received(:debug).with("ET < Start bulk creation (ERROR) - #{resp_body}")
      end
    end
  end

  describe "#caseworker_case_create" do
    it "performs the correct http request" do
      # Arrange - stub the url
      stub = stub_request(:post, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/cases").
             with(headers: { "Content-Type": "application/x-www-form-urlencoded" }).
             to_return(body: '{}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_case_create({}, case_type_id: 'mycasetypeid')

      # Assert
      expect(stub).to have_been_requested
    end

    it "returns the correct json" do
      # Arrange - stub the url
      stub_request(:post, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/cases").
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      result = client.caseworker_case_create({}, case_type_id: 'mycasetypeid')

      # Assert
      expect(result).to eql("test" => "value")
    end

    it "uses a tagged logger" do
      # Arrange - stub the url
      stub_request(:post, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/cases").
        to_return(body: '{}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_case_create({}, case_type_id: 'mycasetypeid')

      # Assert
      expect(mock_logger).to have_received(:tagged)
    end

    it "logs the request" do
      # Arrange - stub the url
      url = "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/cases"
      stub_request(:post, url).
        to_return(body: '{}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.caseworker_case_create({ test: :data }, case_type_id: 'mycasetypeid')

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET > Caseworker create case (#{url}) - {\"test\":\"data\"}")
    end

    it "logs the response" do
      # Arrange - stub the url
      resp_body = '{"test":"value"}'
      stub_request(:post, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/cases").
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
      stub_request(:post, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/cases").
        to_return(body: resp_body, headers: default_response_headers, status: 422)

      # Act - Call the method
      action = -> { client.caseworker_case_create({}, case_type_id: 'mycasetypeid') }

      # Assert
      aggregate_failures "Both exception should be raised and log should be recorded" do
        expect(action).to raise_exception(EtCcdClient::Exceptions::UnprocessableEntity)
        expect(mock_logger).to have_received(:debug).with("ET < Case worker create case (ERROR) - #{resp_body}")
      end
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
      stub_request(:post, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/cases").
        to_return(body: resp_body, headers: default_response_headers, status: 422)

      # Act - Call the method
      case_create = -> { client.caseworker_case_create({}, case_type_id: 'mycasetypeid') }

      # Assert
      aggregate_failures "Both exception should be raised and log should be recorded" do
        expect(case_create).to raise_error(EtCcdClient::Exceptions::UnprocessableEntity) do |error|
          expect(error.message).to include("claimantType.claimant_addressUK.PostCode => 1065^&%$£@():?><*& exceed maximum length 14")
        end
        expect(mock_logger).to have_received(:debug).with("ET < Case worker create case (ERROR) - #{resp_body}")
      end
    end

    it "re raises the response with the response body available under error conditions with standard message" do
      # Arrange - stub the url
      resp_body = '{"message": "Unauthorized"}'
      stub_request(:post, "http://data.mock.com/caseworkers/mockuserid/jurisdictions/mockjid/case-types/mycasetypeid/cases").
        to_return(body: resp_body, headers: default_response_headers, status: 401)

      # Act - Call the method
      case_create = -> { client.caseworker_case_create({}, case_type_id: 'mycasetypeid') }

      # Assert
      aggregate_failures "Both exception should be raised and log should be recorded" do
        expect(case_create).to raise_error(EtCcdClient::Exceptions::Base) do |error|
          expect(error.message).to include("Unauthorized")
        end
        expect(mock_logger).to have_received(:debug).with("ET < Case worker create case (ERROR) - #{resp_body}")
      end
    end
  end

  describe "#caseworker_search_by_reference" do

  end

  describe "#caseworker_search_latest_by_reference" do

  end

  describe "#caseworker_cases_pagination_metadata" do

  end

  describe "#upload_file_from_filename" do
    def parse_multipart(request)
      Rack::Multipart::Parser.parse StringIO.new(request.body), request.headers['Content-Length'].to_i, request.headers['Content-Type'], Rack::Multipart::Parser::TEMPFILE_FACTORY, Rack::Multipart::Parser::BUFSIZE, Rack::Utils.default_query_parser
    end

    it "performs the correct http request" do
      # Arrange - stub the url
      stub = stub_request(:post, "http://documents.mock.com/documents").
        with(headers: { 'Serviceauthorization'=>'Bearer mockservicetoken', 'Authorization' => 'Bearer mockusertoken', 'Content-Type' => /\Amultipart\/form-data/}).
        to_return(body: '{}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.upload_file_from_filename(File.absolute_path('../fixtures/et1.pdf', __dir__), content_type: 'application/pdf')

      # Assert
      expect(stub).to have_been_requested
    end

    it "has the correct params in the multipart body" do
      # Arrange - stub the url
      last_request = nil
      stub_request(:post, "http://documents.mock.com/documents").
        with(headers: { 'Serviceauthorization'=>'Bearer mockservicetoken', 'Authorization' => 'Bearer mockusertoken', 'Content-Type' => /\Amultipart\/form-data/}) {|request| last_request = request}.
        to_return(body: '{}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.upload_file_from_filename(File.absolute_path('../fixtures/et1.pdf', __dir__), content_type: 'application/pdf')

      # Assert
      expect(parse_multipart(last_request).params).to include('files' => a_hash_including(filename: 'et1.pdf', name: "files", type: "application/pdf", tempfile: instance_of(Tempfile)), 'classification' => 'PUBLIC')
    end

    it "has the correct file in the multipart body" do
      # Arrange - stub the url
      last_request = nil
      stub_request(:post, "http://documents.mock.com/documents").
        with(headers: { 'Serviceauthorization'=>'Bearer mockservicetoken', 'Authorization' => 'Bearer mockusertoken', 'Content-Type' => /\Amultipart\/form-data/}) {|request| last_request = request}.
        to_return(body: '{}', headers: default_response_headers, status: 200)

      # Act - Call the method
      input_file = File.absolute_path('../fixtures/et1.pdf', __dir__)
      client.upload_file_from_filename(input_file, content_type: 'application/pdf')

      # Assert
      file = parse_multipart(last_request).params.dig('files', :tempfile)
      expect(file.size).to eql File.size(input_file)
    end

    it "performs the correct hash from the json" do
      # Arrange - stub the url
      stub_request(:post, "http://documents.mock.com/documents").
        with(headers: { 'Serviceauthorization'=>'Bearer mockservicetoken', 'Authorization' => 'Bearer mockusertoken', 'Content-Type' => /\Amultipart\/form-data/}).
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      result = client.upload_file_from_filename(File.absolute_path('../fixtures/et1.pdf', __dir__), content_type: 'application/pdf')

      # Assert
      expect(result).to eql("test" => "value")
    end

    it "uses a tagged logger" do
      # Arrange - stub the url
      stub_request(:post, "http://documents.mock.com/documents").
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.upload_file_from_filename(File.absolute_path('../fixtures/et1.pdf', __dir__), content_type: 'application/pdf')

      # Assert
      expect(mock_logger).to have_received(:tagged)
    end

    it "logs the request" do
      # Arrange - stub the url
      stub_request(:post, "http://documents.mock.com/documents").
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      filename = File.absolute_path('../fixtures/et1.pdf', __dir__)
      client.upload_file_from_filename(filename, content_type: 'application/pdf')

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET > Upload file from filename (#{filename})")
    end

    it "logs the response" do
      # Arrange - stub the url
      resp_body = '{"test":"value"}'
      stub_request(:post, "http://documents.mock.com/documents").
        to_return(body: resp_body, headers: default_response_headers, status: 200)

      # Act - Call the method
      client.upload_file_from_filename(File.absolute_path('../fixtures/et1.pdf', __dir__), content_type: 'application/pdf')

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET < Upload file from filename - #{resp_body}")
    end

    it "logs the response under error conditions" do
      # Arrange - stub the url
      resp_body = '{"message": "Not found"}'
      stub_request(:post, "http://documents.mock.com/documents").
        to_return(body: resp_body, headers: default_response_headers, status: 404)

      # Act - Call the method
      action = -> { client.upload_file_from_filename(File.absolute_path('../fixtures/et1.pdf', __dir__), content_type: 'application/pdf') }

      # Assert
      aggregate_failures "Both exception should be raised and log should be recorded" do
        expect(action).to raise_exception(EtCcdClient::Exceptions::Base)
        expect(mock_logger).to have_received(:debug).with("ET < Upload file from filename (ERROR) - #{resp_body}")
      end
    end


  end

  describe "#upload_file_from_url" do
    def parse_multipart(request)
      Rack::Multipart::Parser.parse StringIO.new(request.body), request.headers['Content-Length'].to_i, request.headers['Content-Type'], Rack::Multipart::Parser::TEMPFILE_FACTORY, Rack::Multipart::Parser::BUFSIZE, Rack::Utils.default_query_parser
    end

    before do
      stub_request(:get, "http://external.server/et1.pdf").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip, deflate',
            'Host'=>'external.server',
            'User-Agent'=>'rest-client/2.0.2 (darwin18.6.0 x86_64) ruby/2.5.1p57'
          }).
        to_return(status: 200, body: File.new(File.absolute_path('../fixtures/et1.pdf', __dir__)), headers: {'Content-Type' => 'application/pdf'})
    end

    it "performs the correct http request" do
      # Arrange - stub the url
      stub = stub_request(:post, "http://documents.mock.com/documents").
        with(headers: { 'Serviceauthorization'=>'Bearer mockservicetoken', 'Authorization' => 'Bearer mockusertoken', 'Content-Type' => /\Amultipart\/form-data/}).
        to_return(body: '{}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.upload_file_from_url('http://external.server/et1.pdf', content_type: 'application/pdf')

      # Assert
      expect(stub).to have_been_requested
    end

    it "has the correct params in the multipart body" do
      # Arrange - stub the url
      last_request = nil
      stub_request(:post, "http://documents.mock.com/documents").
        with(headers: { 'Serviceauthorization'=>'Bearer mockservicetoken', 'Authorization' => 'Bearer mockusertoken', 'Content-Type' => /\Amultipart\/form-data/}) {|request| last_request = request}.
        to_return(body: '{}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.upload_file_from_url('http://external.server/et1.pdf', content_type: 'application/pdf')

      # Assert
      expect(parse_multipart(last_request).params).to include('files' => a_hash_including(filename: instance_of(String), name: "files", type: "application/pdf", tempfile: instance_of(Tempfile)), 'classification' => 'PUBLIC')
    end

    it "has the correct file in the multipart body" do
      # Arrange - stub the url
      last_request = nil
      stub_request(:post, "http://documents.mock.com/documents").
        with(headers: { 'Serviceauthorization'=>'Bearer mockservicetoken', 'Authorization' => 'Bearer mockusertoken', 'Content-Type' => /\Amultipart\/form-data/}) {|request| last_request = request}.
        to_return(body: '{}', headers: default_response_headers, status: 200)

      # Act - Call the method
      input_file = File.absolute_path('../fixtures/et1.pdf', __dir__)
      client.upload_file_from_url('http://external.server/et1.pdf', content_type: 'application/pdf')

      # Assert
      file = parse_multipart(last_request).params.dig('files', :tempfile)
      expect(file.size).to eql File.size(input_file)
    end

    it "performs the correct hash from the json" do
      # Arrange - stub the url
      stub_request(:post, "http://documents.mock.com/documents").
        with(headers: { 'Serviceauthorization'=>'Bearer mockservicetoken', 'Authorization' => 'Bearer mockusertoken', 'Content-Type' => /\Amultipart\/form-data/}).
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      result = client.upload_file_from_url('http://external.server/et1.pdf', content_type: 'application/pdf')

      # Assert
      expect(result).to eql("test" => "value")
    end

    it "uses a tagged logger" do
      # Arrange - stub the url
      stub_request(:post, "http://documents.mock.com/documents").
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      client.upload_file_from_url('http://external.server/et1.pdf', content_type: 'application/pdf')

      # Assert
      expect(mock_logger).to have_received(:tagged)
    end

    it "logs the request" do
      # Arrange - stub the url
      stub_request(:post, "http://documents.mock.com/documents").
        to_return(body: '{"test":"value"}', headers: default_response_headers, status: 200)

      # Act - Call the method
      input_url = 'http://external.server/et1.pdf'
      client.upload_file_from_url(input_url, content_type: 'application/pdf')

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET > Upload file from url (#{input_url})")
    end

    it "logs the response" do
      # Arrange - stub the url
      resp_body = '{"test":"value"}'
      stub_request(:post, "http://documents.mock.com/documents").
        to_return(body: resp_body, headers: default_response_headers, status: 200)

      # Act - Call the method
      client.upload_file_from_url('http://external.server/et1.pdf', content_type: 'application/pdf')

      # Assert
      expect(mock_logger).to have_received(:debug).with("ET < Upload file from url - #{resp_body}")
    end

    it "logs the response under error conditions" do
      # Arrange - stub the url
      resp_body = '{"message": "Not found"}'
      stub_request(:post, "http://documents.mock.com/documents").
        to_return(body: resp_body, headers: default_response_headers, status: 404)

      # Act - Call the method
      action = -> { client.upload_file_from_url('http://external.server/et1.pdf', content_type: 'application/pdf') }

      # Assert
      aggregate_failures "Both exception should be raised and log should be recorded" do
        expect(action).to raise_exception(EtCcdClient::Exceptions::Base)
        expect(mock_logger).to have_received(:debug).with("ET < Upload file from url (ERROR) - #{resp_body}")
      end
    end


  end

  describe ".use" do
    before do
      stub_request(:post, "http://localhost:4502/lease").to_return(body: 'servicetoken', status: 200)
      stub_request(:post, "http://localhost:4501/loginUser").to_return(body: '{"access_token":"usertoken"}', status: 200)
      stub_request(:get, "http://localhost:4501/details").to_return(body: '{"id":"userid","roles":["role1","role2"]}', status: 200)
    end
    it 'fetches a connection from the pool' do
      # Act
      described_class.use do |client|
        # Assert
        expect(client).to be_an_instance_of(described_class)
      end
    end

    it 'ensures it is logged in ready for use' do
      # Setup - call use
      stub_request(:get, "http://localhost:4452/caseworkers/userid/jurisdictions/EMPLOYMENT/case-types/anything/event-triggers/initiateCase/token").
        with(
          headers: {
            'Authorization'=>'Bearer usertoken',
            'Serviceauthorization'=>'Bearer servicetoken',
            'User-Id'=>'userid',
            'User-Roles'=>'role1,role2'
          }).
        to_return(status: 200, body: "{}", headers: {})

      described_class.use do |client|
        # Act - Try and use an endpoint
        client.caseworker_start_case_creation(case_type_id: 'anything')


      end
    end

    it 'checks out from the pool' do
      # Arrange
      was_available = described_class.connection_pool.available
      # Act
      described_class.use do |_client|
        # Assert
        expect(described_class.connection_pool.available).to eql(was_available - 1)
      end
    end

    it 'checks back into the pool' do
      # Arrange
      was_available = described_class.connection_pool.available

      # Act
      described_class.use { |_client| }

      # Assert
      expect(described_class.connection_pool.available).to eql(was_available)
    end

    it 'checks 2 clients out from the same pool if 2 threads are used' do
      # Arrange
      was_available = described_class.connection_pool.available

      # Act
      thread1 = Thread.new do
        described_class.use do |client1|
          Thread.stop
        end
      end

      thread2 = Thread.new do
        described_class.use do |client2|
          Thread.stop
        end
      end

      sleep 0.1 until thread1.status == 'sleep' && thread2.status == 'sleep'

      expect(described_class.connection_pool.available).to eql(was_available - 2)
      thread1.run
      thread2.run
      thread1.join
      thread2.join
    end
  end

end
