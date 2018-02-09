# frozen_string_literal: true

require "savon"

module Docdata
  module Order
    # Client for the Docdata Order API.
    class Client
      XMLNS_DDP = "http://www.docdatapayments.com/services/paymentservice/1_3/"
      DDP_VERSION = "1.3"

      def initialize(name, password, options = {})
        @options = options.merge(merchant: { name: name, password: password })
      end

      def create(options = {})
        params = @options.merge(options)

        response = client.call(:create, message: CreateRequest.new(params), attributes: { xmlns: XMLNS_DDP, version: DDP_VERSION })

        raise Exception, response unless response.success?

        CreateResponse.new(params, response)
      end

      def start(options = {})
        params = @options.merge(options)

        response = client.call(:start, message: StartRequest.new(params), attributes: { xmlns: XMLNS_DDP, version: DDP_VERSION })

        raise Exception, response unless response.success?

        StartResponse.new(params, response)
      end

      def status(options = {})
        params = @options.merge(options)

        response = client.call(:status_extended, message: ExtendedStatusRequest.new(params), attributes: { xmlns: XMLNS_DDP, version: DDP_VERSION })

        raise Exception, response unless response.success?

        ExtendedStatusResponse.new(params, response)
      end

      private

      def client
        @client ||= begin
          params = { wsdl: wsdl_url, raise_errors: false, namespace_identifier: nil, namespaces: { "xmlns:ddp" => XMLNS_DDP } }

          if @options[:debug]
            params.merge!(log: true, log_level: :debug, pretty_print_xml: true)
          end

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
