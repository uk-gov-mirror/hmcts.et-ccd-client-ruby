require "addressable/template"
require 'rest_client'
require 'et_ccd_client/config'
module EtCcdClient
  class IdamClient
    attr_reader :service_token, :user_token

    def initialize(config: ::EtCcdClient.config)
      self.config = config
      self.logger = config.logger
      self.service_token = nil
      self.user_token = nil
    end

    def login(user_id: config.user_id, role: config.user_role)
      logger.tagged('EtCcdClient::IdamClient') do
        self.service_token = exchange_service_token unless service_token.present?
        self.user_token = exchange_user_token(user_id, role) unless user_token.present?
      end
    end

    private

    attr_writer :service_token, :user_token
    attr_accessor :config, :logger

    def exchange_service_token
      url = config.idam_service_token_exchange_url
      data = { microservice: config.microservice }.to_json
      logger.debug("ET > Idam service token exchange (#{url}) - #{data}")
      resp = RestClient.post(url, data, content_type: 'application/json')
      resp.body.tap do |resp_body|
        logger.debug "ET < Idam service token exchange - #{resp_body}"
      end
    end

    def exchange_user_token(user_id, user_role)
      url = config.idam_user_token_exchange_url
      logger.debug("ET > Idam user token exchange (#{url}) - id: #{id} role: #{user_role}")
      resp = RestClient.post(url, id: user_id, role: user_role)
      resp.body.tap do |resp_body|
        logger.debug "ET < Idam user token exchange - #{resp_body}"
      end
    end
  end
end
