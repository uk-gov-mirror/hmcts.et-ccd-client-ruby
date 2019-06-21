require "addressable/template"
require 'rest_client'
require 'et_ccd_client/idam_client'
require 'et_ccd_client/config'
require 'json'
module EtCcdClient
  class Client
    def initialize(idam_client: IdamClient.new, config: ::EtCcdClient.config)
      self.idam_client = idam_client
      self.config = config
      self.logger = config.logger
    end

    def login
      idam_client.login
    end

    # Initiate the case ready for creation
    # @param [String] case_type_id
    #
    # @return [Hash] The json response
    def caseworker_start_case_creation(case_type_id:)
      logger.tagged('EtCcdClient::Client') do
        tpl = Addressable::Template.new(config.initiate_case_url)
        url = tpl.expand(uid: config.user_id, jid: config.jurisdiction_id, ctid: case_type_id, etid: config.initiate_claim_event_id).to_s
        logger.debug("ET > Start case creation (#{url})")
        resp = RestClient.get(url, content_type: 'application/json', 'ServiceAuthorization' => "Bearer #{idam_client.service_token}", :authorization => "Bearer #{idam_client.user_token}")
        resp_body = resp.body
        logger.debug "ET < Start case creation - #{resp_body}"
        JSON.parse(resp_body)
      end
    end

    # @param [Hash] data
    # @param [String] case_type_id
    #
    # @return [Hash] The json response
    def caseworker_case_create(data, case_type_id:)
      logger.tagged('EtCcdClient::Client') do
        tpl = Addressable::Template.new(config.create_case_url)
        url = tpl.expand(uid: config.user_id, jid: config.jurisdiction_id, ctid: case_type_id).to_s
        logger.debug("ET > Caseworker create case (#{url}) - #{data.to_json}")
        resp = RestClient.post(url, data, content_type: 'application/json', 'ServiceAuthorization' => "Bearer #{idam_client.service_token}", :authorization => "Bearer #{idam_client.user_token}")
        resp_body = resp.body
        logger.debug "ET < Case worker create case - #{resp_body}"
        JSON.parse(resp_body)
      end
    end

    def caseworker_search_by_reference(reference, case_type_id:, page: 1, sort_direction: 'desc')
      tpl = Addressable::Template.new(config.cases_url)
      url = tpl.expand(uid: config.user_id, jid: config.jurisdiction_id, ctid: case_type_id, query: { 'case.feeGroupReference' => reference, page: page, 'sortDirection' => sort_direction }).to_s
      resp = RestClient.get(url, content_type: 'application/json', accept: 'application/json', 'ServiceAuthorization' => "Bearer #{idam_client.service_token}", :authorization => "Bearer #{idam_client.user_token}")
      JSON.parse(resp.body)
    end

    def caseworker_search_latest_by_reference(reference, case_type_id:)
      results = caseworker_search_by_reference(reference, case_type_id: case_type_id, page: 1, sort_direction: 'desc')
      results.first
    end

    def caseworker_cases_pagination_metadata(case_type_id:, query: {})
      tpl = Addressable::Template.new(config.cases_pagination_metadata_url)
      url = tpl.expand(uid: config.user_id, jid: config.jurisdiction_id, ctid: case_type_id, query: query).to_s
      meta_resp = RestClient.get(url, content_type: 'application/json', accept: 'application/json', 'ServiceAuthorization' => "Bearer #{idam_client.service_token}", :authorization => "Bearer #{idam_client.user_token}")
      JSON.parse(meta_resp)
    end

    private

    attr_accessor :idam_client, :config, :logger
  end
end
