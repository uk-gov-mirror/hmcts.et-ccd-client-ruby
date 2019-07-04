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
      tpl = Addressable::Template.new(config.cases_path)
      path = tpl.expand(uid: ui_idam_client.user_details['id'], jid: config.jurisdiction_id, ctid: case_type_id, query: { 'case.feeGroupReference' => reference, page: page, 'sortDirection' => sort_direction }).to_s
      url = "#{remote_config.api_url}#{path}"
      resp = RestClient::Request.execute(method: :get, url: url, headers: { content_type: 'application/json', accept: 'application/json' }, cookies: { accessToken: ui_idam_client.user_token })
      JSON.parse(resp.body)["results"]
    end

    # Search for the latest case matching the reference.  Useful for testing
    # @param [String] reference The reference number to search for
    # @param [String] case_type_id The case type ID to set the search scope to
    # @return [Hash] The case object returned from the server
    def caseworker_search_latest_by_reference(reference, case_type_id:)
      results = caseworker_search_by_reference(reference, case_type_id: case_type_id, page: 1, sort_direction: 'desc')
      results.first
    end

    private

    attr_accessor :ui_idam_client, :config, :remote_config, :logger
  end
end
