module EtCcdClient
  module CommonRestClient
    def get_request(url, log_subject:, extra_headers: {}, decode: true, cookies: {})
      logger.debug("ET > #{log_subject} (#{url})")
      req = RestClient::Request.new(method: :get, url: url, headers: { content_type: 'application/json' }.merge(extra_headers), cookies: cookies, verify_ssl: config.verify_ssl)
      resp = req.execute
      logger.debug "ET < #{log_subject} - #{resp.body}"
      decode ? JSON.parse(resp.body) : resp.body
    rescue RestClient::Exception => e
      logger.debug "ET < #{log_subject} (ERROR) - #{e.response.body}"
      Exceptions::Base.raise_exception(e, url: url, request: req)
    end

    def post_request(url, data, log_subject:, extra_headers: {}, decode: true, cookies: {})
      logger.debug("ET > #{log_subject} (#{url}) - #{data.to_json}")
      req = RestClient::Request.new(method: :post, url: url, payload: data, headers: { content_type: 'application/json' }.merge(extra_headers), cookies: cookies, verify_ssl: config.verify_ssl)
      resp = req.execute
      logger.debug "ET < #{log_subject} - #{resp.body}"
      decode ? JSON.parse(resp.body) : resp.body
    rescue RestClient::Exception => e
      logger.debug "ET < #{log_subject} (ERROR) - #{e.response.body}"
      Exceptions::Base.raise_exception(e, url: url, request: req)
    end
  end
end
