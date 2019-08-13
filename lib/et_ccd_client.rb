require "et_ccd_client/version"
require 'et_ccd_client/null_logger'
require 'et_ccd_client/config'
require 'et_ccd_client/idam_client'
require 'et_ccd_client/tidam_client'
require 'et_ccd_client/client'
require 'et_ccd_client/ui_client'
require 'et_ccd_client/exceptions'
require 'et_ccd_client/uploaded_file'

module EtCcdClient
  class Error < StandardError; end

  def self.config
    yield Config.instance if block_given?
    Config.instance
  end
end
