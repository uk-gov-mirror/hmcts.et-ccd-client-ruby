require 'singleton'
require 'et_ccd_client/null_logger'
require 'addressable/template'
module EtCcdClient
  class Config
    include Singleton

    attr_accessor :auth_base_url, :idam_base_url, :data_store_base_url, :idam_ui_base_url
    attr_accessor :user_role, :user_id
    attr_accessor :jurisdiction_id, :microservice, :microservice_secret
    attr_accessor :logger
    attr_accessor :verify_ssl, :use_sidam, :sidam_username, :sidam_password
    attr_accessor :idam_ui_redirect_url, :idam_ui_client_id

    def idam_service_token_exchange_url
      "#{auth_base_url}/lease"
    end

    def idam_user_token_exchange_url
      use_sidam ? "#{idam_base_url}/loginUser" : "#{idam_base_url}/testing-support/lease"
    end

    def create_case_url
      "#{data_store_base_url}/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/cases"
    end

    def cases_url
      "#{data_store_base_url}/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/cases{?query*}"
    end

    def cases_pagination_metadata_url
      "#{data_store_base_url}/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/cases/pagination_metadata{?query*}"
    end

    def initiate_case_url
      "#{data_store_base_url}/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/event-triggers/{etid}/token"
    end

    def initiate_claim_event_id
      'initiateCase'
    end

    def idam_ui_config_url
      "#{idam_ui_base_url}/config"
    end

    private

    def initialize
      self.auth_base_url = 'http://localhost:4502'
      self.idam_base_url =  'http://localhost:4501'
      self.data_store_base_url = 'http://localhost:4452'
      self.idam_ui_base_url = 'https://localhost:3451'
      self.idam_ui_redirect_url = 'http://localhost:3451/oauth2redirect'
      self.user_id = 22
      self.user_role = 'caseworker,caseworker-test,caseworker-employment-tribunal-manchester,caseworker-employment,caseworker-employment-tribunal-manchester-caseofficer,caseworker-publiclaw-localAuthority'
      self.jurisdiction_id = 'EMPLOYMENT'
      self.microservice = 'ccd_gw'
      self.microservice_secret = 'AAAAAAAAAAAAAAAC'
      self.logger = NullLogger.new
      self.verify_ssl = true
      self.use_sidam = false
      self.sidam_username = 'm@m.com'
      self.sidam_password = 'p'
    end
  end
end
