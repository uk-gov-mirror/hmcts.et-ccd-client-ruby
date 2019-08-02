require "addressable/template"
require 'rest_client'
require 'et_ccd_client/ui_idam_client'
require 'et_ccd_client/config'
require 'et_ccd_client/exceptions'
require 'et_ccd_client/common_rest_client'
require 'json'
require 'forwardable'
module EtCcdClient
  # A client to interact with the CCD UI API (front end)
  class UiClient
    extend Forwardable
    include CommonRestClient

    def initialize(ui_idam_client: UiIdamClient.new, config: ::EtCcdClient.config, remote_config: ::EtCcdClient.ui_remote_config)
      self.ui_idam_client = ui_idam_client
      self.config = config
      self.remote_config = remote_config
      self.logger = config.logger
    end

    delegate login: :ui_idam_client

    # Search for cases by reference - useful for testing
    # @param [String] reference The reference number to search for
    # @param [String] case_type_id The case type ID to set the search scope to
    # @param [Integer] page - The page number to fetch
    # @param [String] sort_direction (defaults to 'desc') - Change to 'asc' to do oldest first
    #
    # @return [Array<Hash>] The json response from the server
    def caseworker_search_by_reference(reference, case_type_id:, page: 1, sort_direction: 'desc')
      logger.tagged('EtCcdClient::UiClient') do
        tpl = Addressable::Template.new(config.cases_path)
        path = tpl.expand(uid: ui_idam_client.user_details['id'], jid: config.jurisdiction_id, ctid: case_type_id, query: { 'case.feeGroupReference' => reference, page: page, 'sortDirection' => sort_direction }).to_s
        url = "#{config.gateway_api_url}/aggregated#{path}"
        resp = get_request(url, log_subject: 'Caseworker search by reference', extra_headers: { content_type: 'application/json', accept: 'application/json' }, cookies: { accessToken: ui_idam_client.user_token })
        unless config.document_store_url_rewrite == false
          resp = reverse_rewrite_document_store_urls(resp)
        end
        resp["results"]
      end
    end

    # Search for the latest case matching the reference.  Useful for testing
    # @param [String] reference The reference number to search for
    # @param [String] case_type_id The case type ID to set the search scope to
    # @return [Hash] The case object returned from the server
    def caseworker_search_latest_by_reference(reference, case_type_id:)
      results = caseworker_search_by_reference(reference, case_type_id: case_type_id, page: 1, sort_direction: 'desc')
      results.first
    end

    # Search for cases by ethos case reference - useful for testing
    # @param [String] reference The ethos case reference number to search for
    # @param [String] case_type_id The case type ID to set the search scope to
    # @param [Integer] page - The page number to fetch
    # @param [String] sort_direction (defaults to 'desc') - Change to 'asc' to do oldest first
    #
    # @return [Array<Hash>] The json response from the server
    def caseworker_search_by_ethos_case_reference(reference, case_type_id:, page: 1, sort_direction: 'desc')
      logger.tagged('EtCcdClient::UiClient') do
        tpl = Addressable::Template.new(config.cases_path)
        path = tpl.expand(uid: ui_idam_client.user_details['id'], jid: config.jurisdiction_id, ctid: case_type_id, query: { 'case.ethosCaseReference' => reference, page: page, 'sortDirection' => sort_direction }).to_s
        url = "#{config.gateway_api_url}/aggregated#{path}"
        resp = get_request(url, log_subject: 'Caseworker search by ethos case reference', extra_headers: { content_type: 'application/json', accept: 'application/json' }, cookies: { accessToken: ui_idam_client.user_token })
        unless config.document_store_url_rewrite == false
          resp = reverse_rewrite_document_store_urls(resp)
        end
        resp["results"]
      end
    end

    # Search for the latest case matching the ethos case reference.  Useful for testing
    # @param [String] reference The ethos case reference number to search for
    # @param [String] case_type_id The case type ID to set the search scope to
    # @return [Hash] The case object returned from the server
    def caseworker_search_latest_by_ethos_case_reference(reference, case_type_id:)
      results = caseworker_search_by_ethos_case_reference(reference, case_type_id: case_type_id, page: 1, sort_direction: 'desc')
      results.first
    end

    # Search for cases by multiples reference - useful for testing
    # @param [String] reference The multiples reference number to search for
    # @param [String] case_type_id The case type ID to set the search scope to
    # @param [Integer] page - The page number to fetch
    # @param [String] sort_direction (defaults to 'desc') - Change to 'asc' to do oldest first
    #
    # @return [Array<Hash>] The json response from the server
    def caseworker_search_by_multiple_reference(reference, case_type_id:, page: 1, sort_direction: 'desc')
      logger.tagged('EtCcdClient::UiClient') do
        tpl = Addressable::Template.new(config.cases_path)
        path = tpl.expand(uid: ui_idam_client.user_details['id'], jid: config.jurisdiction_id, ctid: case_type_id, query: { 'case.multipleReference' => reference, page: page, 'sortDirection' => sort_direction }).to_s
        url = "#{config.gateway_api_url}/aggregated#{path}"
        resp = get_request(url, log_subject: 'Case worker search by multiple reference', extra_headers: { content_type: 'application/json', accept: 'application/json' }, cookies: { accessToken: ui_idam_client.user_token })
        resp["results"]
      end
    end

    # Search for the latest case matching the multiple reference.  Useful for testing
    # @param [String] reference The multiples reference number to search for
    # @param [String] case_type_id The case type ID to set the search scope to
    # @return [Hash] The case object returned from the server
    def caseworker_search_latest_by_multiple_reference(reference, case_type_id:)
      results = caseworker_search_by_multiple_reference(reference, case_type_id: case_type_id, page: 1, sort_direction: 'desc')
      results.first
    end

    private

    attr_accessor :ui_idam_client, :config, :remote_config, :logger

    def reverse_rewrite_document_store_urls(json)
      source_host, source_port, dest_host, dest_port = config.document_store_url_rewrite
      JSON.parse(JSON.generate(json).gsub(/(https?):\/\/#{dest_host}:#{dest_port}/, "\\1://#{source_host}:#{source_port}"))
    end
  end
end
