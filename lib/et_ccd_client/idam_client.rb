require "addressable/template"
require 'rest_client'
require 'et_ccd_client/config'
module EtCcdClient
  class IdamClient
    attr_reader :service_token, :user_token
    
    def initialize(config: ::EtCcdClient.config)
      self.config = config
      self.service_token = nil
      self.user_token = nil
    end
    
    def login(user_id: config.user_id, role: config.user_role)
      self.service_token = exchange_service_token unless service_token.present?
      self.user_token = exchange_user_token(user_id, role) unless user_token.present?
    end
    
    private
    
    attr_writer :service_token, :user_token
    attr_accessor :config
    
    def exchange_service_token
      url = config.idam_service_token_exchange_url
      resp = RestClient.post(url, { microservice: config.microservice }.to_json, content_type: 'application/json')
      resp.body
    end
    
    def exchange_user_token(user_id, user_role)
      url = config.idam_user_token_exchange_url
      resp = RestClient.post(url, id: user_id, role: user_role)
      resp.body
    end
  end
end
