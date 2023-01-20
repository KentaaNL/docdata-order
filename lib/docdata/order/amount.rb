# frozen_string_literal: true

require 'bigdecimal'

module Docdata
  module Order
    # Helper for converting/formatting amounts.
    class Amount
      class << self
        def from_cents(cents)
          new(cents.to_i / 100.0)
        end
      end

      def initialize(amount)
        @amount = BigDecimal(amount.to_s)
      end

      def to_d
        @amount
      end

      def to_amount
        @amount / 100.0
      end

      def to_cents
        cents = @amount * 100
        cents.to_i
      end

      # Convert the amount to a String with 2 decimals.
      def to_s
        format('%.2f', @amount)
      end
    end
  end
end
