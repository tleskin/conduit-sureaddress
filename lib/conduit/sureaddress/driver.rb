module Conduit
  module Driver
    module Sureaddress
      extend Conduit::Core::Driver

      required_credentials :client_number, :validation_key
      optional_attributes  :host_override, :mock_status

      action :verify_address
    end
  end
end
