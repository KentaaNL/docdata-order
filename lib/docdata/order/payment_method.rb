# frozen_string_literal: true

module Docdata
  module Order
    # Payment method in Docdata, optionally with issuers.
    class PaymentMethod
      IDEAL = "IDEAL"
      VISA = "VISA"
      MASTER_CARD = "MASTERCARD"
      MAESTRO = "MAESTRO"
      AMERICAN_EXPRESS = "AMEX"
      PAYPAL = "PAYPAL_EXPRESS_CHECKOUT"
      SEPA_DIRECT_DEBIT = "SEPA_DIRECT_DEBIT"

      attr_accessor :payment_method, :issuers

      def initialize(payment_method)
        @payment_method = payment_method
      end

      def to_s
        payment_method
      end
    end
  end
end
