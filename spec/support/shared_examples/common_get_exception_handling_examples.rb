RSpec.shared_examples "common GET exception handling examples" do
  it "raises an error with the url present if the server responds with an error" do
    # Arrange - stub the url
    resp_body = '{"message": "Not found"}'
    stub_request(:get, url).
      to_return(body: resp_body, headers: default_response_headers, status: 404)

    # Assert
    expect(action).to raise_exception(EtCcdClient::Exceptions::Base, "404 Not Found - Not found ('#{url}')")
  end

end
