# frozen_string_literal: true

module Docdata
  module Order
    module Urls
      # WSDL location, see Order API 1.3.
      WSDL_LIVE_URL = "https://secure.docdatapayments.com/ps/services/paymentservice/1_3?wsdl"
      WSDL_TEST_URL = "https://testsecure.docdatapayments.com/ps/services/paymentservice/1_3?wsdl"

      # Payment Menu base URL, see Functional API.
      MENU_LIVE_URL = "https://secure.docdatapayments.com/ps/menu"
      MENU_TEST_URL = "https://testsecure.docdatapayments.com/ps/menu"
    end
  end
end
