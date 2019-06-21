require "et_ccd_client/version"
require 'et_ccd_client/config'
require 'et_ccd_client/idam_client'
require 'et_ccd_client/client'

module EtCcdClient
  class Error < StandardError; end
  
  def self.config
    yield Config.instance if block_given?
    Config.instance
  end
end
