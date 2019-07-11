require "addressable/template"
require 'rest_client'
require 'et_ccd_client/idam_client'
require 'et_ccd_client/config'
require 'et_ccd_client/exceptions'
require 'json'
require 'forwardable'
module EtCcdClient
  # A client to interact with the CCD API (backend)
  class Client
    extend Forwardable

    def initialize(idam_client: nil, config: ::EtCcdClient.config)
      self.idam_client = idam_client || (config.use_sidam ? IdamClient.new : TidamClient.new)
      self.config = config
      self.logger = config.logger
    end

    delegate login: :idam_client

    # Initiate the case ready for creation
    # @param [String] case_type_id
    #
    # @return [Hash] The json response
    def caseworker_start_case_creation(case_type_id:)
      logger.tagged('EtCcdClient::Client') do
        url = initiate_case_url(case_type_id)
        logger.debug("ET > Start case creation (#{url})")
        resp = RestClient::Request.execute(method: :get, url: url, headers: { content_type: 'application/json', 'ServiceAuthorization' => "Bearer #{idam_client.service_token}", :authorization => "Bearer #{idam_client.user_token}", 'user-id' => idam_client.user_details['id'], 'user-roles' => idam_client.user_details['roles'].join(',') }, verify_ssl: config.verify_ssl)
        logger.debug "ET < Start case creation - #{resp.body}"
        JSON.parse(resp.body)
      rescue RestClient::Exception => e
        logger.debug "ET < Start case creation (ERROR) - #{e.response.body}"
        raise
      end
    end

    # @param [Hash] data
    # @param [String] case_type_id
    #
    # @return [Hash] The json response
    def caseworker_case_create(data, case_type_id:)
      logger.tagged('EtCcdClient::Client') do
        tpl = Addressable::Template.new(config.create_case_url)
        url = tpl.expand(uid: idam_client.user_details['id'], jid: config.jurisdiction_id, ctid: case_type_id).to_s
        logger.debug("ET > Caseworker create case (#{url}) - #{data.to_json}")
        resp = RestClient::Request.execute(method: :post, url: url, payload: data, headers: { content_type: 'application/json', 'ServiceAuthorization' => "Bearer #{idam_client.service_token}", :authorization => "Bearer #{idam_client.user_token}" }, verify_ssl: config.verify_ssl)
        resp_body = resp.body
        logger.debug "ET < Case worker create case - #{resp_body}"
        JSON.parse(resp_body)
      rescue RestClient::Exception => e
        logger.debug "ET < Case worker create case (ERROR) - #{e.response.body}"
        raise Exceptions::Base.raise_exception(e)
      end
    end

    # Search for cases by reference - useful for testing
    # @param [String] reference The reference number to search for
    # @param [String] case_type_id The case type ID to set the search scope to
    # @param [Integer] page - The page number to fetch
    # @param [String] sort_direction (defaults to 'desc') - Change to 'asc' to do oldest first
    #
    # @return [Array<Hash>] The json response from the server
    def caseworker_search_by_reference(reference, case_type_id:, page: 1, sort_direction: 'desc')
      tpl = Addressable::Template.new(config.cases_url)
      url = tpl.expand(uid: idam_client.user_details['id'], jid: config.jurisdiction_id, ctid: case_type_id, query: { 'case.feeGroupReference' => reference, page: page, 'sortDirection' => sort_direction }).to_s
      resp = RestClient.get(url, content_type: 'application/json', accept: 'application/json', 'ServiceAuthorization' => "Bearer #{idam_client.service_token}", :authorization => "Bearer #{idam_client.user_token}")
      JSON.parse(resp.body)
    end

    # Search for the latest case matching the reference.  Useful for testing
    # @param [String] reference The reference number to search for
    # @param [String] case_type_id The case type ID to set the search scope to
    # @return [Hash] The case object returned from the server
    def caseworker_search_latest_by_reference(reference, case_type_id:)
      results = caseworker_search_by_reference(reference, case_type_id: case_type_id, page: 1, sort_direction: 'desc')
      results.first
    end

    # Search for cases by multiple reference - useful for testing
    # @param [String] reference The multiples reference number to search for
    # @param [String] case_type_id The case type ID to set the search scope to
    # @param [Integer] page - The page number to fetch
    # @param [String] sort_direction (defaults to 'desc') - Change to 'asc' to do oldest first
    #
    # @return [Array<Hash>] The json response from the server
    def caseworker_search_by_multiple_reference(reference, case_type_id:, page: 1, sort_direction: 'desc')
      tpl = Addressable::Template.new(config.cases_url)
      url = tpl.expand(uid: idam_client.user_details['id'], jid: config.jurisdiction_id, ctid: case_type_id, query: { 'case.multipleReference' => reference, page: page, 'sortDirection' => sort_direction }).to_s
      resp = RestClient.get(url, content_type: 'application/json', accept: 'application/json', 'ServiceAuthorization' => "Bearer #{idam_client.service_token}", :authorization => "Bearer #{idam_client.user_token}")
      JSON.parse(resp.body)
    end

    # Search for the latest case matching the multiples reference.  Useful for testing
    # @param [String] reference The multiples reference number to search for
    # @param [String] case_type_id The case type ID to set the search scope to
    # @return [Hash] The case object returned from the server
    def caseworker_search_latest_by_multiple_reference(reference, case_type_id:)
      results = caseworker_search_by_multiple_reference(reference, case_type_id: case_type_id, page: 1, sort_direction: 'desc')
      results.first
    end

    def caseworker_cases_pagination_metadata(case_type_id:, query: {})
      tpl = Addressable::Template.new(config.cases_pagination_metadata_url)
      url = tpl.expand(uid: idam_client.user_details['id'], jid: config.jurisdiction_id, ctid: case_type_id, query: query).to_s
      meta_resp = RestClient.get(url, content_type: 'application/json', accept: 'application/json', 'ServiceAuthorization' => "Bearer #{idam_client.service_token}", :authorization => "Bearer #{idam_client.user_token}")
      JSON.parse(meta_resp)
    end

    private

    def initiate_case_url(case_type_id)
      tpl = Addressable::Template.new(config.initiate_case_url)
      tpl.expand(uid: idam_client.user_details['id'], jid: config.jurisdiction_id, ctid: case_type_id, etid: config.initiate_claim_event_id).to_s
    end

    attr_accessor :idam_client, :config, :logger
  end
end
