require 'erb'
require 'tilt'

module Conduit::Sureaddress::RequestMocker
  class Base
    FIXTURE_PREFIX = "#{File.dirname(__FILE__)}/../../../../spec/fixtures".freeze

    def initialize(base, options = nil)
      @base = base
      @options = options
      @mock_status = options[:mock_status].to_sym || :success
    end

    def mock
      Excon.defaults[:mock] = true
      Excon.stub({}, {:body => response})
    end

    def unmock
      Excon.stubs.clear
      Excon.defaults[:mock] = false
    end

    def with_mocking
      mock and yield.tap { unmock }
    end

    private

    def render_response
      Tilt::ERBTemplate.new(fixture).render(@base.view_context)
    end

    def fixture
      FIXTURE_PREFIX + "/#{action_name}/#{@mock_status}.xml"
    end

    def action_name
      ActiveSupport::Inflector.demodulize(self.class.name).underscore
    end

    def response
      if response_statuses.include?(@mock_status)
        return error_response if @mock_status == :error
        render_response
      else
        raise(ArgumentError, "Mock status must be :success, :failure, or :error")
      end
    end

    def response_statuses
      %i(success failure error)
    end

    def error_response
      '{"status": 500, "error": "Internal Service Error"}'
    end
  end
end
