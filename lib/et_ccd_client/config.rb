require 'singleton'
require 'null_logger'
module EtCcdClient
  class Config
    include Singleton

    attr_accessor :auth_base_url, :idam_base_url, :data_store_base_url
    attr_accessor :user_role, :user_id
    attr_accessor :jurisdiction_id, :microservice
    attr_accessor :logger

    def idam_service_token_exchange_url
      "#{auth_base_url}/testing-support/lease"
    end

    def idam_user_token_exchange_url
      "#{idam_base_url}/testing-support/lease"
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

    private

    def initialize
      self.auth_base_url = 'http://localhost:4502'
      self.idam_base_url =  'http://localhost:4501'
      self.data_store_base_url = 'http://localhost:4452'
      self.user_id = 22
      self.user_role = 'caseworker,caseworker-test,caseworker-employment-tribunal-manchester,caseworker-employment,caseworker-employment-tribunal-manchester-caseofficer,caseworker-publiclaw-localAuthority'
      self.jurisdiction_id = 'EMPLOYMENT'
      self.microservice = 'ccd_gw'
      self.logger = NullLogger.new
    end
  end
end
