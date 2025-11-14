# frozen_string_literal: true

require 'docdata/order/amount'
require 'docdata/order/client'
require 'docdata/order/exception'
require 'docdata/order/gender'
require 'docdata/order/payment_method'
require 'docdata/order/request'
require 'docdata/order/response'
require 'docdata/order/urls'
require 'docdata/order/version'

require 'logger'

module Docdata
  # :nodoc:
  module Order
    # Holds the global Docdata::Order configuration.
    class Configuration
      attr_accessor :logger, :open_timeout, :read_timeout

      def initialize
        @logger = Rails.logger if defined?(Rails)
        @open_timeout = 30
        @read_timeout = 30
      end
    end

    class << self
      def config
        @config ||= Configuration.new
      end

      def configure
        yield(config)
      end

      def reset!
        @config = Configuration.new
      end
    end
  end
end
