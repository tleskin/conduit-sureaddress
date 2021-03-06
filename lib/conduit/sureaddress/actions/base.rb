require 'forwardable'

module Conduit::Driver::Sureaddress
  class Base < Conduit::Core::Action
    extend Forwardable

    def_delegators :'self.class', :http_method, :url_route

    class << self
      def self.inherited(base)
        base.send :required_attributes, *(Conduit::Driver::Sureaddress.credentials)
        base.send :required_attributes,
          *(Conduit::Driver::Sureaddress.required_attributes)
        base.send :optional_attributes,
          *(Conduit::Driver::Sureaddress.optional_attributes)
      end

      def http_method(http_method = nil)
        @http_method = http_method unless http_method.nil?
        @http_method
      end

      def url_route(url_route = nil)
        @url_route = url_route unless url_route.nil?
        @url_route
      end
    end

    def remote_url
      if host_override?
        @options[:host_override] + url_route
      else
        Conduit::Sureaddress::Configuration.api_host + url_route
      end
    end

    def view_context
      view_decorator.new(
        OpenStruct.new(attributes_with_values)
      )
    end

    def attributes_with_values
      attributes.inject({}) do |hash, attribute|
        hash.tap do |h|
          h[attribute] = @options[attribute]
        end
      end.tap do |h|
        h[:client_number]  = @options[:client_number]
        h[:validation_key] = @options[:validation_key]
      end
    end

    def perform
      if mock_mode?
        mocker = request_mocker.new(self, @options)
        mocker.with_mocking { perform_request }
      else
        perform_request
      end
    end

    def perform_request
      response = request(body: request_body, method: http_method, headers: http_headers)
      parser   = parser_class.new(response.body, response.status)
      Conduit::ApiResponse.new(raw_response: response, parser: parser)
    end

    private

    def http_headers
      {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
    end

    def request_body
      URI.escape("request=#{view}")
    end

    def action_name
      ActiveSupport::Inflector.demodulize(self.class)
    end

    def request_mocker
      "Conduit::Sureaddress::RequestMocker::#{action_name}".constantize
    end

    def view_decorator
      "Conduit::Sureaddress::Decorators::#{action_name}Decorator".constantize
    end

    def mock_mode?
      option_key_present?(:mock_status)
    end

    def host_override?
      option_key_present?(:host_override)
    end

    def option_key_present?(key)
      option_value = @options[key]
      !(option_value.nil? || option_value.empty?)
    end
  end
end
