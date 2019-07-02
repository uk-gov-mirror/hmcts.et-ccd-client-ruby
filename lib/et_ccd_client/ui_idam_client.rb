require "addressable/template"
require "addressable/uri"
require 'et_ccd_client/config'
require 'mechanize'
module EtCcdClient
  class UiIdamClient
    attr_reader :service_token, :user_token

    def initialize(config: ::EtCcdClient.config)
      self.config = config
      self.logger = config.logger
      self.agent = Mechanize.new
      agent.verify_mode = config.verify_ssl ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
    end

    def login(username: config.sidam_username, password: config.sidam_password)
      logger.tagged('EtCcdClient::UiIdamClient') do
        self.user_token = exchange_sidam_user_token(username, password)
      end
    end

    private

    attr_writer :user_token
    attr_accessor :config, :logger, :agent

    def exchange_sidam_user_token(username, password)
      url = login_url
      logger.debug("ET > IdamUI user token exchange (#{url}) - username: #{username} password: '******'")
      get_access_token(get_oauth_code(url, password, username)).tap do |token|
        logger.debug "ET < IdamUI user token exchange - #{token}"
      end
    end

    def get_access_token(oauth_code)
      uri = Addressable::URI.parse(dynamic_config['oauth2_token_endpoint_url'])
      uri.query_values = { code: oauth_code, redirect_uri: config.idam_ui_redirect_url }
      page = agent.get(uri.to_s)
      agent.cookies.detect { |cookie| cookie.name == 'accessToken' }.value
    end

    def get_oauth_code(url, password, username)
      agent.get(url)
      form = agent.current_page.form_with(name: 'loginForm')
      form.username = username
      form.password = password
      form.submit
      Addressable::URI.parse(agent.current_page.uri).query_values['code']
    end

    def login_url
      uri = Addressable::URI.parse dynamic_config['login_url']
      uri.query_values = {
          response_type: :code,
          client_id: dynamic_config['oauth2_client_id'],
          redirect_uri: config.idam_ui_redirect_url
      }
      uri.to_s
    end

    def dynamic_config
      @dynamic_config ||= JSON.parse(agent.get(config.idam_ui_config_url).body)
    end
  end
end

