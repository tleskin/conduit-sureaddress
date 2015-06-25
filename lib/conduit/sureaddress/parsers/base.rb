require 'cgi'
require 'nokogiri'

module Conduit::Driver::Sureaddress
  module Parser
    # Base XML parser for Sureaddress responses.
    # Includes parsing of errors and invalid
    # content.  Subclasses must address
    # parsing of specific attributes.
    class Base < Conduit::Core::Parser
      attr_accessor :xml

      def initialize(xml, http_status = nil)
        unescaped_xml = CGI.unescapeHTML(xml)
        @xml = Nokogiri::XML(unescaped_xml).css('string AddressResponse').to_s
        @http_status = http_status || 200
      end

      # Return "success/failure". This gets
      # returned to the request object
      # as a type of notification
      #
      def response_status
        if response_content?
          code = string_path('/AddressResponse/ReturnCode/text()')
          response_status_from_code(code)
        else
          'error'
        end
      end

      # Return an array of error objects
      #
      # e.g.
      # parser.errors
      # => [{"code"=>nil, "message"=>"Unable to locate telephone by MDN"}]
      #
      def response_errors
        return if response_status == 'success'

        if response_content?
          { error: string_path('/AddressResponse/Message/text()') }
        else
          { error: 'Unexpected response from server.' }
        end
      end

      private

      def response_content?
        !object_path('/AddressResponse').empty?
      end

      # Return a Nokogiri::XML object
      #
      # @xml must be set. You can either set
      # it in the initializer, or assign it
      # manually, but it must be set.
      #
      def doc
        @doc ||= Nokogiri::XML(@xml)
      end

      # Return a attribute/element object from doc
      #
      # e.g.
      # object_path('//resources/@timestamp')
      # => [#<Nokogiri::XML... name="timestamp" value="20140130180057">]
      #
      def object_path(path, node = doc)
        node.xpath(path)
      end

      # Return a string from a attribute/element
      #
      # e.g.
      # string_path('//resources/@timestamp')
      # => 20140130180057
      #
      def string_path(path, node = doc)
        object_path(path, node).to_s
      end

      def response_status_from_code(code)
        code = code.to_i
        return 'failure' if [1, 2, 3].include?(code)
        return 'success' if [100, 101, 102].include?(code)
        return 'error'   if code == 999
      end
    end
  end
end
