# frozen_string_literal: true

require "uri"

module Docdata
  module Order
    # Base class for responses.
    class Response
      attr_reader :options, :response

      def initialize(options, response)
        @options = options
        @response = response
      end

      def body
        response.body
      end

      def error_message
        errors[:error] if errors
      end

      def error_code
        errors[:error].attributes["code"] if errors
      end
    end

    # Response to a create operation.
    class CreateResponse < Response
      def data
        body[:create_response]
      end

      def success?
        data.key?(:create_success)
      end

      def error?
        data.key?(:create_errors)
      end

      def errors
        data[:create_errors]
      end

      def order_key
        data[:create_success][:key]
      end

      def redirect_url
        params = {
          command: "show_payment_cluster",
          merchant_name: merchant_name,
          client_language: client_language,
          payment_cluster_key: order_key
        }

        if payment_method
          params[:default_pm] = payment_method

          case payment_method
          when PaymentMethod::IDEAL
            params[:default_act] = true
            params[:ideal_issuer_id] = issuer_id if issuer_id
          when PaymentMethod::PAYPAL
            params[:default_act] = true
          end
        end

        if return_url
          params.merge!(
            return_url_success: build_return_url("success"),
            return_url_canceled: build_return_url("cancelled"),
            return_url_pending: build_return_url("pending"),
            return_url_error: build_return_url("error")
          )
        end

        uri = URI.parse(redirect_base_url)
        uri.query = URI.encode_www_form(params)
        uri.to_s
      end

      private

      def redirect_base_url
        if options[:test]
          Urls::MENU_TEST_URL
        else
          Urls::MENU_LIVE_URL
        end
      end

      def merchant_name
        # Use subject merchant when present, otherwise fallback to merchant.
        if options[:subject_merchant]
          options.fetch(:subject_merchant).fetch(:name)
        else
          options.fetch(:merchant).fetch(:name)
        end
      end

      def client_language
        options.fetch(:shopper).fetch(:language)
      end

      def payment_method
        options[:payment_method].to_s
      end

      def issuer_id
        options[:issuer_id]
      end

      def return_url
        options[:return_url]
      end

      def build_return_url(status)
        uri = URI.parse(return_url)
        query = URI.decode_www_form(uri.query || "") << ["status", status]
        uri.query = URI.encode_www_form(query)
        uri.to_s
      end
    end

    # Response to a start operation.
    class StartResponse < Response
      def data
        body[:start_response]
      end

      def success?
        data.key?(:start_success)
      end

      def error?
        data.key?(:start_errors)
      end

      def errors
        data[:start_errors]
      end

      def payment_response
        data[:start_success][:payment_response]
      end

      def payment_success
        payment_response[:payment_success] if payment_response
      end

      def payment_id
        payment_success[:id] if payment_success
      end
    end

    # Response to a extended status operation.
    class ExtendedStatusResponse < Response
      def data
        body[:extended_status_response]
      end

      def success?
        data.key?(:status_success)
      end

      def error?
        data.key?(:status_errors)
      end

      def errors
        data[:status_errors]
      end

      def report
        data[:status_success][:report]
      end

      def payment
        payment = report[:payment]

        # When multiple payments are found, return the payment with the newest ID.
        if payment.is_a?(Array)
          payment.max_by { |key, _value| key[:id] }
        else
          payment
        end
      end

      def payment_id
        payment[:id] if payment
      end

      def payment_method
        payment[:payment_method] if payment
      end

      def authorization
        payment[:authorization] if payment
      end

      # The state of the authorization. Current known values:
      #                           NEW   This is a new payment without any actions performed on it yet.
      #                 RISK_CHECK_OK   For this payment the risk check was okay.
      #             RISK_CHECK_FAILED   The risk check for this payment triggered.
      #                       STARTED   The user has provided details and is authenticated.
      #                   START_ERROR   The payment system could not start the payment due to a technical error.
      #                 AUTHENTICATED   The shopper is authenticated by the acquirer.
      # REDIRECTED_FOR_AUTHENTICATION   The shopper is redirected to the acquirer web-site for authentication.
      #         AUTHENTICATION_FAILED   The shopper is not authenticated by the acquirer.
      #          AUTHENTICATION_ERROR   Unable to do the authentication of the shopper by the acquirer.
      #                    AUTHORIZED   This payment is authorized.
      #  REDIRECTED_FOR_AUTHORIZATION   The shopper is redirected to the acquirer web-site for authorization.
      #       AUTHORIZATION_REQUESTED   Requested authorization for this payment, waiting for a notification from acquirer.
      #          AUTHORIZATION_FAILED   The payment was not authorized due to a functional error.
      #           AUTHORIZATION_ERROR   Unable to do the payment authorization due to a technical error.
      #                      CANCELED   The payment is canceled.
      #                 CANCEL_FAILED   Payment is not canceled, due to functional error.
      #                  CANCEL_ERROR   Payment is not canceled, due to technical error.
      #              CANCEL_REQUESTED   A cancel request sent to acquirer.
      def authorization_status
        authorization[:status] if authorization
      end

      def approximate_totals
        report[:approximate_totals]
      end

      def total_registered
        to_decimal(approximate_totals[:total_registered])
      end

      def total_shopper_pending
        to_decimal(approximate_totals[:total_shopper_pending])
      end

      def total_acquirer_pending
        to_decimal(approximate_totals[:total_acquirer_pending])
      end

      def total_acquirer_approved
        to_decimal(approximate_totals[:total_acquirer_approved])
      end

      def total_captured
        to_decimal(approximate_totals[:total_captured])
      end

      def total_refunded
        to_decimal(approximate_totals[:total_refunded])
      end

      def total_reversed
        to_decimal(approximate_totals[:total_reversed])
      end

      def total_charged_back
        to_decimal(approximate_totals[:total_chargedback])
      end

      def paid?
        (total_registered == total_captured) || (total_registered == total_acquirer_approved)
      end

      def refunded?
        total_registered == total_refunded
      end

      def charged_back?
        total_registered == total_charged_back
      end

      def reversed?
        total_registered == total_reversed
      end

      def started?
        (authorization_status == "NEW" || authorization_status == "STARTED" ||
          (total_captured.zero? && total_acquirer_approved.zero?)) && authorization_status != "CANCELED"
      end

      def cancelled?
        authorization_status == "CANCELED"
      end

      def consumer_iban
        case payment_method
        when PaymentMethod::IDEAL
          payment_info = payment[:extended][:i_deal_payment_info]
          payment_info[:shopper_bank_account][:iban] if payment_info && payment_info[:shopper_bank_account]
        when PaymentMethod::SEPA_DIRECT_DEBIT
          payment_info = payment[:extended][:sepa_direct_debit_payment_info]
          payment_info[:iban] if payment_info
        end
      end

      def consumer_bic
        case payment_method
        when PaymentMethod::IDEAL
          payment_info = payment[:extended][:i_deal_payment_info]
          payment_info[:shopper_bank_account][:bic] if payment_info && payment_info[:shopper_bank_account]
        when PaymentMethod::SEPA_DIRECT_DEBIT
          payment_info = payment[:extended][:sepa_direct_debit_payment_info]
          payment_info[:bic] if payment_info
        end
      end

      def consumer_name
        if payment_method == PaymentMethod::IDEAL
          payment_info = payment[:extended][:i_deal_payment_info]
          payment_info[:holder_name] if payment_info
        end
      end

      def mandate_number
        if payment_method == PaymentMethod::SEPA_DIRECT_DEBIT
          payment_info = payment[:extended][:sepa_direct_debit_payment_info]
          payment_info[:mandate_number] if payment_info
        end
      end

      private

      def to_decimal(cents)
        Amount.from_cents(cents).to_d
      end
    end

    # Response to a refund operation.
    class RefundResponse < Response
      def data
        body[:refund_response]
      end

      def success?
        data.key?(:refund_success)
      end

      def error?
        data.key?(:refund_errors)
      end

      def errors
        data[:refund_errors]
      end
    end

    # Response to a list payment methods operation.
    class ListPaymentMethodsResponse < Response
      def data
        body[:list_payment_methods_response]
      end

      def success?
        data.key?(:list_payment_methods_success)
      end

      def error?
        data.key?(:list_payment_methods_errors)
      end

      def errors
        data[:list_payment_methods_errors]
      end

      def payment_methods
        data[:list_payment_methods_success][:payment_method].map do |payment_method|
          method = PaymentMethod.new(payment_method[:name])
          method.issuers = payment_method[:issuers][:issuer].map { |issuer| [issuer.attributes["id"], issuer.to_s] }.to_h if payment_method.key?(:issuers)
          method
        end
      end
    end
  end
end
