require "addressable/template"
require 'rest_client'
require 'et_ccd_client/ui_idam_client'
require 'et_ccd_client/config'
require 'et_ccd_client/exceptions'
require 'json'
require 'forwardable'
module EtCcdClient
  # A client to interact with the CCD UI API (front end)
  class UiClient
    extend Forwardable

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
        url = "#{remote_config.api_url}#{path}"
        logger.debug("ET > Caseworker search by reference (#{url})")
        resp = RestClient::Request.execute(method: :get, url: url, headers: { content_type: 'application/json', accept: 'application/json' }, cookies: { accessToken: ui_idam_client.user_token }, proxy: config.proxy)
        resp_body = resp.body
        logger.debug("ET < Case worker search by reference - #{resp_body}")
        unless config.document_store_url_rewrite == false
          resp_body = reverse_rewrite_document_store_urls(resp_body)
        end
        JSON.parse(resp_body)["results"]
      rescue RestClient::Exception => e
        logger.debug "ET < Case worker search by reference (ERROR) - #{e&.response&.body}"
        raise Exceptions::Base.raise_exception(e)
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
        url = "#{remote_config.api_url}#{path}"
        logger.debug("ET > Caseworker search by ethos case reference (#{url})")
        resp = RestClient::Request.execute(method: :get, url: url, headers: { content_type: 'application/json', accept: 'application/json' }, cookies: { accessToken: ui_idam_client.user_token }, proxy: config.proxy)
        resp_body = resp.body
        logger.debug("ET < Case worker search by ethos case reference - #{resp_body}")
        unless config.document_store_url_rewrite == false
          resp_body = reverse_rewrite_document_store_urls(resp_body)
        end
        JSON.parse(resp_body)["results"]
      rescue RestClient::Exception => e
        logger.debug "ET < Case worker search by ethos case reference (ERROR) - #{e.response.body}"
        raise Exceptions::Base.raise_exception(e)
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
        url = "#{remote_config.api_url}#{path}"
        logger.debug("ET > Caseworker search by multiple reference (#{url})")
        resp = RestClient::Request.execute(method: :get, url: url, headers: { content_type: 'application/json', accept: 'application/json' }, cookies: { accessToken: ui_idam_client.user_token }, proxy: config.proxy)
        logger.debug("ET < Case worker search by multiple reference - #{resp.body}")
        JSON.parse(resp.body)["results"]
      rescue RestClient::Exception => e
        logger.debug "ET < Case worker search by multiple reference (ERROR) - #{e.response.body}"
        raise Exceptions::Base.raise_exception(e)
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

    def reverse_rewrite_document_store_urls(body)
      source_host, source_port, dest_host, dest_port = config.document_store_url_rewrite
      body.gsub(/(https?):\/\/#{dest_host}:#{dest_port}/, "\\1://#{source_host}:#{source_port}")
    end

  end
end
