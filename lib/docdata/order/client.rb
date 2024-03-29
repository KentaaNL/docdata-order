# frozen_string_literal: true

require 'savon'

module Docdata
  module Order
    # Client for the Docdata Order API.
    class Client
      XMLNS_DDP = 'http://www.docdatapayments.com/services/paymentservice/1_3/'
      DDP_VERSION = '1.3'

      def initialize(name, password, options = {})
        @options = options.merge(merchant: { name: name, password: password })
      end

      def create(options = {})
        params = @options.merge(options)
        response = call(:create, CreateRequest.new(params))

        CreateResponse.new(params, response)
      end

      def start(options = {})
        params = @options.merge(options)
        response = call(:start, StartRequest.new(params))

        StartResponse.new(params, response)
      end

      def status(options = {})
        params = @options.merge(options)
        response = call(:status_extended, ExtendedStatusRequest.new(params))

        ExtendedStatusResponse.new(params, response)
      end

      def refund(options = {})
        params = @options.merge(options)
        response = call(:refund, RefundRequest.new(params))

        RefundResponse.new(params, response)
      end

      def payment_methods(options = {})
        params = @options.merge(options)
        response = call(:list_payment_methods, ListPaymentMethodsRequest.new(params))

        ListPaymentMethodsResponse.new(params, response)
      end

      private

      def call(operation, message)
        client.call(operation, message: message, attributes: { xmlns: XMLNS_DDP, version: DDP_VERSION })
      rescue Savon::Error => e
        raise Docdata::Order::Exception, e.message
      end

      def client
        @client ||= begin
          params = { wsdl: wsdl_url, raise_errors: true, namespace_identifier: nil, namespaces: { 'xmlns:ddp' => XMLNS_DDP } }

          params.merge!(log: true, log_level: :debug, pretty_print_xml: true) if @options[:debug]

          params[:logger] = Rails.logger if defined?(Rails)

          Savon.client(params)
        end
      end

      def wsdl_url
        if @options[:test]
          Urls::WSDL_TEST_URL
        else
          Urls::WSDL_LIVE_URL
        end
      end
    end
  end
end
