module EtCcdClient
  module Exceptions
    class Base < ::StandardError
      attr_reader :original_exception, :response, :message

      def self.raise_exception(original_exception)
        expected_error_class = original_exception.class.name.split('::').last
        if EtCcdClient::Exceptions.const_defined?(expected_error_class)
          raise EtCcdClient::Exceptions.const_get(expected_error_class), original_exception
        else
          raise self, original_exception
        end
      end

      def self.exception(*args)
        new(*args)
      end

      def initialize(original_exception)
        self.original_exception = original_exception
      end

      def message
        original_exception.message
      end

      def response
        original_exception.response
      end

      private

      attr_writer :original_exception
    end
  end
end