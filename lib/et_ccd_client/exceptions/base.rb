module EtCcdClient
  module Exceptions
    class Base < ::StandardError
      attr_reader :original_exception, :response, :url

      def self.raise_exception(original_exception, **kw_args)
        expected_error_class = original_exception.class.name.split('::').last
        if EtCcdClient::Exceptions.const_defined?(expected_error_class)
          raise EtCcdClient::Exceptions.const_get(expected_error_class).new original_exception, **kw_args
        else
          raise new(original_exception, **kw_args)
        end
      end

      def self.exception(*args, **kw_args)
        new(*args, **kw_args)
      end

      def initialize(original_exception, url: nil)
        self.original_exception = original_exception
        self.url = url
      end

      def response
        original_exception.response
      end

      def to_s
        json = JSON.parse(response.body) rescue JSON::JSONError
        message = if json.nil? || json == JSON::JSONError
          ''
        else
          json['message'] || ''
        end
        if url
          "#{original_exception.message} - #{message} ('#{url}')"
        else
          "#{original_exception.message} - #{message}"
        end
      end

      private

      attr_writer :original_exception, :url
    end
  end
end
