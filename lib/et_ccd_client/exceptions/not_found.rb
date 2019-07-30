module EtCcdClient
  module Exceptions
    class NotFound < Base
      def to_s
        json = JSON.parse(response.body) rescue JSON::JSONError
        return "Not Found" if json.nil?

        super
      end

    end
  end
end
