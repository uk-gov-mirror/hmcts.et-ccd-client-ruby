RSpec.shared_examples 'common GET logging examples' do |log_subject:|
  it "uses a tagged logger" do
    # Arrange - stub the url
    stub_request(:get, url).
      to_return(body: '{"test":"value"}', status: 200)

    # Act - Call the method
    action.call

    # Assert
    expect(mock_logger).to have_received(:tagged)
  end

  it "logs the request" do
    # Arrange - stub the url
    stub_request(:get, url).
      to_return(body: '{"test":"value"}', status: 200)

    # Act - Call the method
    action.call

    # Assert
    expect(mock_logger).to have_received(:debug).with("ET > #{log_subject} (#{url})")
  end

  it "logs the response" do
    # Arrange - stub the url
    resp_body = '{"test":"value"}'
    stub_request(:get, url).
      to_return(body: resp_body, status: 200)

    # Act - Call the method
    action.call

    # Assert
    expect(mock_logger).to have_received(:debug).with("ET < #{log_subject} - #{resp_body}")
  end

  it "logs the response under error conditions" do
    # Arrange - stub the url
    resp_body = '{"message": "Not found"}'
    stub_request(:get, url).
      to_return(body: resp_body, status: 404)

    # Act and Assert
    aggregate_failures "Both exception should be raised and log should be recorded" do
      expect(action).to raise_exception(EtCcdClient::Exceptions::Base)
      expect(mock_logger).to have_received(:debug).with("ET < #{log_subject} (ERROR) - #{resp_body}")
    end
  end

end
