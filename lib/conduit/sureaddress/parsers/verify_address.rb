require 'conduit/sureaddress/parsers/base'
require 'bigdecimal'

module Conduit::Driver::Sureaddress
  class VerifyAddress::Parser < Parser::Base
    attribute :client_number do
      string_path('/AddressResponse/ClientNumber/text()')
    end

    attribute :business_unit do
      string_path('/AddressResponse/BusinessUnit/text()')
    end

    attribute :client_tracking do
      string_path('/AddressResponse/ClientTracking/text()')
    end

    attribute :score do
      BigDecimal.new(string_path('/AddressResponse/Score/text()'))
    end

    attribute :firm_name do
      string_path('/AddressResponse/FirmName/text()')
    end

    attribute :primary_address_line do
      string_path('/AddressResponse/PrimaryAddressLine/text()')
    end

    attribute :secondary_address_line do
      string_path('/AddressResponse/SecondaryAddressLine/text()')
    end

    attribute :city do
      string_path('/AddressResponse/City/text()')
    end

    attribute :urbanization do
      string_path('/AddressResponse/Urbanization/text()')
    end

    attribute :county do
      string_path('/AddressResponse/County/text()')
    end

    attribute :state do
      string_path('/AddressResponse/State/text()')
    end

    attribute :zip_code do
      string_path('/AddressResponse/ZIPCode/text()')
    end

    attribute :zip_plus_4 do
      string_path('/AddressResponse/ZIPPlus4/text()')
    end

    attribute :latitude do
      BigDecimal.new(string_path('/AddressResponse/Latitude/text()'))
    end

    attribute :longitude do
      BigDecimal.new(string_path('/AddressResponse/Longitude/text()'))
    end

    attribute :time_zone do
      string_path('/AddressResponse/TimeZone/text()').to_i
    end

    attribute :daylight_saving? do
      string_path('/AddressResponse/DayLightSaving/text()') == 'true'
    end

    attribute :match_limit_exceeded? do
      string_path('/AddressResponse/IsMatchLimitExceed/text()') == 'true'
    end

    attribute :geocode do
      string_path('/AddressResponse/GeoCode/text()')
    end

    attribute :top_match_unique? do
      string_path('/AddressResponse/TopMatchUnique/text()') == 'true'
    end
  end
end
