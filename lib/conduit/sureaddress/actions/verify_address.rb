require 'conduit/sureaddress/actions/base'

module Conduit::Driver::Sureaddress
  class VerifyAddress < Base
    url_route   '/SureAddress.asmx/PostRequest'
    required_attributes :response_type, :match_count
    optional_attributes :client_tracking, :firm_name, :primary_address_line,
                        :secondary_address_line, :urbanization, :city, :county,
                        :state, :zip_code, :zip_plus_4, :business_unit
    http_method :post
  end
end
