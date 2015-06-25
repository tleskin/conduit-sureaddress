require 'conduit/sureaddress/request_mocker/base'

module Conduit::Sureaddress::RequestMocker
  class VerifyAddress < Base
    private

    def response_statuses
      %i(success failure error low_confidence)
    end
  end
end
