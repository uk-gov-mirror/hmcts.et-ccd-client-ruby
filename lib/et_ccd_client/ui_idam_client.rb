require "addressable/template"
require "addressable/uri"
require 'et_ccd_client/config'
module EtCcdClient
  class UiIdamClient
    attr_reader :service_token, :user_token, :user_details

    def initialize(config: ::EtCcdClient.config)
      self.config = config
      self.logger = config.logger
      self.user_details = nil
    end

    def login(username: config.sidam_username, password: config.sidam_password)
      logger.tagged('EtCcdClient::UiIdamClient') do
        self.user_token = exchange_sidam_user_token(username, password)
        self.user_details = get_user_details
      end
    end

    private

    attr_writer :user_token, :user_details
    attr_accessor :config, :logger

    def exchange_sidam_user_token(username, password)
      url = "#{config.idam_base_url}/loginUser"
      logger.debug("ET > IdamUI user token exchange (#{url}) - username: #{username} password: '******'")
      resp = RestClient::Request.execute(method: :post, url: url, payload: {username: username, password: password}, headers: { content_type: 'application/x-www-form-urlencoded', accept: 'application/json' }, verify_ssl: config.verify_ssl)
      token = JSON.parse(resp.body)['access_token']
      logger.debug "ET < IdamUI user token exchange - #{token}"
      token
    end

    def get_user_details
      url = "#{config.idam_base_url}/details"
      logger.debug("ET > UiIdam get user details (#{url})")
      resp = RestClient::Request.execute(method: :get, url: url, headers: { 'Accept' => 'application/json', 'Authorization' => user_token }, verify_ssl: config.verify_ssl)
      resp_body = resp.body
      logger.debug "ET < UiIdam get user details : #{resp_body}"
      JSON.parse(resp_body)
    end
  end
end

