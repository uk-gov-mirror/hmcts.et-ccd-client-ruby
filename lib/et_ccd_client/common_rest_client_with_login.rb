module EtCcdClient
  module CommonRestClientWithLogin

    private

    def get_request_with_login(*args)
      login_on_forbidden do
        get_request(*args)
      end
    end

    def post_request_with_login(*args)
      login_on_forbidden do
        post_request(*args)
      end
    end

    def login_on_forbidden
      retried = false
      begin
        yield
      rescue EtCcdClient::Exceptions::Forbidden => e
        raise if retried

        retried = true
        logger.tagged('Re logging in') do
          login
        end
        retry
      end
    end
  end
end
