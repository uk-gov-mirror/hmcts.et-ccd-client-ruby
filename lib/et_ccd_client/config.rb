require 'singleton'
module EtCcdClient
  class Config
    include Singleton

    def idam_service_token_exchange_url
      'http://localhost:4502/testing-support/lease'
    end

    def idam_user_token_exchange_url
      'http://localhost:4501/testing-support/lease'
    end

    def create_case_url
      'http://localhost:4452/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/cases'
    end

    def cases_url
      'http://localhost:4452/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/cases{?query*}'
    end

    def cases_pagination_metadata_url
      'http://localhost:4452/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/cases/pagination_metadata{?query*}'
    end

    def initiate_case_url
      'http://localhost:4452/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/event-triggers/{etid}/token'
    end

    def user_id
      22
    end

    def user_role
      'caseworker,caseworker-test,caseworker-employment-tribunal-manchester,caseworker-employment,caseworker-employment-tribunal-manchester-caseofficer,caseworker-publiclaw-localAuthority'
    end

    def secret
      'AAAAAAAAAAAAAAAC'
    end

    def jurisdiction_id
      'EMPLOYMENT'
    end

    def case_type_id
      'EmpTrib_MVP_1.0_Manc'
    end

    def initiate_claim_event_id
      'initiateCase'
    end
    
    def microservice
      'ccd_gw'
    end
  end
end
