require "addressable/template"
require 'rest_client'
require 'et_ccd_client/idam_client'
require 'et_ccd_client/config'
require 'et_ccd_client/exceptions'
require 'json'
require 'forwardable'
require 'connection_pool'
module EtCcdClient
  # A client to interact with the CCD API (backend)
  class Client
    extend Forwardable

    def initialize(idam_client: nil, config: ::EtCcdClient.config)
      self.idam_client = idam_client || (config.use_sidam ? IdamClient.new : TidamClient.new)
      self.config = config
      self.logger = config.logger
    end

    def self.use(&block)
      connection_pool.with(&block)
    end

    def self.connection_pool(config: ::EtCcdClient.config)
      @connection_pool ||= ConnectionPool.new(size: config.pool_size, timeout: config.pool_timeout) do
        new.tap do |client|
          client.login
        end
      end
    end

    delegate login: :idam_client

    # Initiate the case ready for creation
    # @param [String] case_type_id
    #
    # @return [Hash] The json response
    def caseworker_start_case_creation(case_type_id:)
      logger.tagged('EtCcdClient::Client') do
        url = initiate_case_url(case_type_id, config.initiate_claim_event_id)
        logger.debug("ET > Start case creation (#{url})")
        resp = RestClient::Request.execute(method: :get, url: url, headers: { content_type: 'application/json', 'ServiceAuthorization' => "Bearer #{idam_client.service_token}", :authorization => "Bearer #{idam_client.user_token}", 'user-id' => idam_client.user_details['id'], 'user-roles' => idam_client.user_details['roles'].join(',') }, verify_ssl: config.verify_ssl)
        logger.debug "ET < Start case creation - #{resp.body}"
        JSON.parse(resp.body)
      rescue RestClient::Exception => e
        logger.debug "ET < Start case creation (ERROR) - #{e.response.body}"
        Exceptions::Base.raise_exception(e, url: url)
      end
    end

    # Initiate a bulk action case ready for creation
    # @param [String] case_type_id
    #
    # @return [Hash] The json response
    def caseworker_start_bulk_creation(case_type_id:)
      logger.tagged('EtCcdClient::Client') do
        url = initiate_case_url(case_type_id, config.initiate_bulk_event_id)
        logger.debug("ET > Start bulk creation (#{url})")
        resp = RestClient::Request.execute(method: :get, url: url, headers: { content_type: 'application/json', 'ServiceAuthorization' => "Bearer #{idam_client.service_token}", :authorization => "Bearer #{idam_client.user_token}", 'user-id' => idam_client.user_details['id'], 'user-roles' => idam_client.user_details['roles'].join(',') }, verify_ssl: config.verify_ssl)
        logger.debug "ET < Start bulk creation - #{resp.body}"
        JSON.parse(resp.body)
      rescue RestClient::Exception => e
        logger.debug "ET < Start bulk creation (ERROR) - #{e.response.body}"
        Exceptions::Base.raise_exception(e, url: url)
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
        Exceptions::Base.raise_exception(e, url: url)
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

    # @param [String] filename The full path to the file to upload
    # @return [Hash] The object returned by the server
    def upload_file_from_filename(filename, content_type:)
      upload_file_from_source(filename, content_type: content_type, source_name: :filename, source: filename)
    end

    # @param [String] url The url of the file to upload
    # @return [Hash] The object returned by the server
    def upload_file_from_url(url, content_type:, original_filename: File.basename(url))
      resp = RestClient::Request.execute(method: :get, url: url, raw_response: true, verify_ssl: config.verify_ssl)
      upload_file_from_source(resp.file.path, content_type: content_type, source_name: :url, source: url, original_filename: original_filename)
    end

    private

    def upload_file_from_source(filename, content_type:, source_name:, source:, original_filename: filename)
      logger.tagged('EtCcdClient::Client') do
        url = config.upload_file_url
        logger.debug("ET > Upload file from #{source_name} (#{source})")
        uploaded_file = UploadedFile.new(filename, content_type: content_type, binary: true, original_filename: original_filename)
        data = {
          multipart: true,
          files: uploaded_file,
          classification: 'PUBLIC'
        }
        resp = RestClient::Request.execute(method: :post, url: url, payload: data, headers: { 'ServiceAuthorization' => "Bearer #{idam_client.service_token}", :authorization => "Bearer #{idam_client.user_token}" }, verify_ssl: config.verify_ssl)
        resp_body = resp.body
        logger.debug "ET < Upload file from #{source_name} - #{resp_body}"
        unless config.document_store_url_rewrite == false
          resp_body = rewrite_document_store_urls(resp_body)
        end
        JSON.parse(resp_body)
      rescue RestClient::Exception => e
        logger.debug "ET < Upload file from #{source_name} (ERROR) - #{e.response.body}"
        Exceptions::Base.raise_exception(e, url: url)
      end
    end

    def initiate_case_url(case_type_id, event_id)
      tpl = Addressable::Template.new(config.initiate_case_url)
      tpl.expand(uid: idam_client.user_details['id'], jid: config.jurisdiction_id, ctid: case_type_id, etid: event_id).to_s
    end

    def rewrite_document_store_urls(body)
      source_host, source_port, dest_host, dest_port = config.document_store_url_rewrite
      body.gsub(/(https?):\/\/#{source_host}:#{source_port}/, "\\1://#{dest_host}:#{dest_port}")
    end

    attr_accessor :idam_client, :config, :logger
  end
end
