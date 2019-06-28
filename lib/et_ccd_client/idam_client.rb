require "addressable/template"
require 'rest_client'
require 'et_ccd_client/config'
require 'rotp'
module EtCcdClient
  class IdamClient
    attr_reader :service_token, :user_token

    def initialize(config: ::EtCcdClient.config)
      self.config = config
      self.logger = config.logger
      self.service_token = nil
      self.user_token = nil
    end

    def login(username: config.sidam_username, password: config.sidam_password)
      logger.tagged('EtCcdClient::IdamClient') do
        self.service_token = exchange_service_token
        self.user_token = exchange_sidam_user_token(username, password)
      end
    end

    private

    attr_writer :service_token, :user_token
    attr_accessor :config, :logger

    def exchange_service_token
      url = config.idam_service_token_exchange_url
      data = { microservice: config.microservice, oneTimePassword: otp }.to_json
      logger.debug("ET > Idam service token exchange (#{url}) - #{data}")
      resp = RestClient.post(url, data, content_type: 'application/json')
      resp.body.tap do |resp_body|
        logger.debug "ET < Idam service token exchange - #{resp_body}"
      end
    end

    def exchange_sidam_user_token(username, password)
      url = config.idam_user_token_exchange_url
      logger.debug("ET > Idam user token exchange (#{url}) - username: #{username} password: '******'")
      resp = RestClient::Request.execute(method: :post, url: url, payload: { username: username, password: password }, headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }, verify_ssl: config.verify_ssl)
      resp_body = resp.body
      logger.debug "ET < Idam user token exchange - #{resp_body}"
      JSON.parse(resp_body)['access_token']
    end

    def otp
      totp.now
    end

    def totp
      @totp ||= ROTP::TOTP.new(config.microservice_secret)
    end
  end
end
