module Conduit
  module Sureaddress
    module Configuration
      class << self
        attr_accessor :api_host

        def configure(&block)
          yield self
        end
      end

      self.api_host = 'https://testapi.sureaddress.net'
    end
  end
end
