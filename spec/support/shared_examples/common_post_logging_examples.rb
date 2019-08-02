RSpec.shared_examples "common POST logging examples" do |log_subject:|
  it "uses a tagged logger" do
    # Arrange - stub the url
    stub_request(:post, url).
      to_return(body: '{}', status: 200)

    # Act - Call the method
    action.call

    # Assert
    expect(mock_logger).to have_received(:tagged)
  end

  it "logs the request" do
    # Arrange - stub the url
    stub_request(:post, url).
      to_return(body: '{}', status: 200)

    # Act - Call the method
    action.call({ test: :data })

    # Assert
    expect(mock_logger).to have_received(:debug).with("ET > #{log_subject} (#{url}) - {\"test\":\"data\"}")
  end

  it "logs the response" do
    # Arrange - stub the url
    resp_body = '{"test":"value"}'
    stub_request(:post, url).
      to_return(body: resp_body, status: 200)

    # Act - Call the method
    action.call

    # Assert
    expect(mock_logger).to have_received(:debug).with("ET < #{log_subject} - #{resp_body}")
  end

  it "logs the response under error conditions" do
    # Arrange - stub the url
    resp_body = {
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
    stub_request(:post, url).
      to_return(body: resp_body, status: 422)

    # Act and Assert
    aggregate_failures "Both exception should be raised and log should be recorded" do
      expect(action).to raise_exception(EtCcdClient::Exceptions::UnprocessableEntity)
      expect(mock_logger).to have_received(:debug).with("ET < #{log_subject} (ERROR) - #{resp_body}")
    end
  end

end
