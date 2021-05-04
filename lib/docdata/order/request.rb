# frozen_string_literal: true

require "builder/xmlmarkup"
require "securerandom"

module Docdata
  module Order
    # Base class for XML requests to Docdata.
    class Request
      attr_reader :options

      def initialize(options = {})
        @options = options
      end

      def to_s
        builder = Builder::XmlMarkup.new

        # Merchant credentials.
        if subject_merchant
          builder.merchant(name: merchant_name, password: merchant_password) do |merchant|
            # The merchant on whose behalf this request should be executed.
            merchant.subjectMerchant(name: subject_merchant_name, token: subject_merchant_token) do |subject|
              # The fee to apply to the subject merchant. If the fee is zero, then it is ignored. A fee can only be applied to create-order requests.
              subject.fee(moment: subject_merchant_fee_moment) do |fee|
                fee.amount(subject_merchant_fee_amount, currency: subject_merchant_fee_currency)
                fee.description(subject_merchant_fee_description) if subject_merchant_fee_description
              end
            end
          end
        else
          builder.merchant(name: merchant_name, password: merchant_password)
        end

        build_request(builder)

        # This element contains information about the application contacting the webservice.
        # This info is useful when debugging troubleshooting technical integration issues.
        builder.integrationInfo do |integration|
          # The name of the plugin used to contact this webservice.
          integration.webshopPlugin("docdata-order")
          # The version of the plugin used to contact this webservice.
          integration.webshopPluginVersion(Docdata::Order::VERSION)
          # The name of the plugin creator used to contact this webservice.
          integration.integratorName("Kentaa")
          # The programming language used to contact this webservice.
          integration.programmingLanguage("Ruby #{RUBY_VERSION}")
          # The operating system from which this webservice is contacted.
          integration.operatingSystem(RUBY_PLATFORM)
          # The full version number (including minor e.q. 1.3.0)
          # of the xsd which is used during integration. DDP can make minor
          # (non-breaking) changes to the xsd. These are reflected in a minor
          # version number. It can therefore be useful to know if a different
          # minor version of the xsd was used during merchant development than
          # the one currently active in production.
          integration.ddpXsdVersion(Docdata::Order::Client::DDP_VERSION)
        end

        builder.target!
      end

      private

      def merchant_name
        options.fetch(:merchant).fetch(:name)
      end

      def merchant_password
        options.fetch(:merchant).fetch(:password)
      end

      def subject_merchant
        options[:subject_merchant]
      end

      def subject_merchant_name
        subject_merchant.fetch(:name)
      end

      def subject_merchant_token
        subject_merchant.fetch(:token)
      end

      def subject_merchant_fee
        subject_merchant.fetch(:fee)
      end

      def subject_merchant_fee_moment
        subject_merchant_fee[:moment] || "FULLY_PAID"
      end

      def subject_merchant_fee_description
        subject_merchant_fee[:description]
      end

      def subject_merchant_fee_amount
        Amount.new(subject_merchant_fee.fetch(:amount)).to_cents
      end

      def subject_merchant_fee_currency
        subject_merchant_fee[:currency] || "EUR"
      end

      def build_request
        raise NotImplementedError
      end
    end

    # Create an Order in the Docdata system.
    class CreateRequest < Request
      def build_request(builder)
        # Unique merchant reference to this order.
        builder.merchantOrderReference(order_reference)

        # Preferences to use for this payment.
        builder.paymentPreferences do |preferences|
          # The profile that is used to select the payment methods that can be used to pay this order.
          preferences.profile(profile)
          preferences.numberOfDaysToPay(14)
        end

        # Information concerning the shopper who placed the order.
        builder.shopper(id: shopper_id) do |shopper|
          # Shopper's full name.
          shopper.name do |name|
            # The first given name.
            name.first(shopper_first_name)
            # Any subsequent given name or names. May also be used as middle initial.
            name.middle(shopper_infix) if shopper_infix
            # The family or inherited name(s).
            name.last(shopper_last_name)
          end

          # Shopper's e-mail address.
          shopper.email(shopper_email)
          # Shopper's preferred language. Language code according to ISO 639.
          shopper.language(code: shopper_language)
          # Shopper's gender.
          shopper.gender(shopper_gender)
          # Ip address of the shopper. Will be used in the future for riskchecks. Can be ipv4 or ipv6.
          shopper.ipAddress(shopper_ip_address) if shopper_ip_address
        end

        # Total order gross amount. The amount in the minor unit for the given currency.
        # (E.g. for EUR in cents)
        builder.totalGrossAmount(amount, currency: currency)

        # Name and address to use for billing.
        builder.billTo do |bill|
          bill.name do |name|
            # The first given name.
            name.first(shopper_first_name)
            # Any subsequent given name or names. May also be used as middle initial.
            name.middle(shopper_infix) if shopper_infix
            # The family or inherited name(s).
            name.last(shopper_last_name)
          end
          # Address of the destination.
          bill.address do |address|
            # Address lines must be filled as specific as possible using the house number
            # and optionally the house number addition field.
            address.street(address_street)
            # The house number.
            address.houseNumber(address_house_number)
            address.postalCode(address_postal_code)
            address.city(address_city)
            # Country code according to ISO 3166.
            address.country(code: address_country)
          end
        end

        # The description of the order.
        builder.description(description)

        # The description that is used by payment providers on shopper statements.
        builder.receiptText(receipt_text)

        # The merchant_reference is used for recurring payments.
        if initial
          builder.paymentRequest do |payment_request|
            payment_request.initialPaymentReference do |payment_reference|
              payment_reference.merchantReference(merchant_reference)
            end
          end
        end
      end

      private

      def amount
        Amount.new(options.fetch(:amount)).to_cents
      end

      def order_reference
        options.fetch(:order_reference)
      end

      def profile
        options.fetch(:profile)
      end

      def shopper_id
        options.fetch(:shopper)[:id] || SecureRandom.hex
      end

      def shopper_first_name
        options.fetch(:shopper).fetch(:first_name)
      end

      def shopper_infix
        options.fetch(:shopper)[:infix]
      end

      def shopper_last_name
        options.fetch(:shopper).fetch(:last_name)
      end

      def shopper_email
        options.fetch(:shopper).fetch(:email)
      end

      def shopper_language
        options.fetch(:shopper).fetch(:language)
      end

      def shopper_gender
        options.fetch(:shopper).fetch(:gender)
      end

      def shopper_ip_address
        options.fetch(:shopper)[:ip_address]
      end

      def address_street
        options.fetch(:address).fetch(:street)
      end

      def address_house_number
        options.fetch(:address).fetch(:house_number)
      end

      def address_postal_code
        options.fetch(:address).fetch(:postal_code)
      end

      def address_city
        options.fetch(:address).fetch(:city)
      end

      def address_country
        options.fetch(:address).fetch(:country)
      end

      def currency
        options[:currency] || "EUR"
      end

      def description
        options.fetch(:description)
      end

      def receipt_text
        options.fetch(:description)[0, 49]
      end

      def initial
        options[:initial]
      end

      def merchant_reference
        initial[:merchant_reference]
      end
    end

    # Start a payment order (Webdirect).
    class StartRequest < Request
      def build_request(builder)
        # Payment order key belonging to the order for which a transaction needs to be started.
        builder.paymentOrderKey(order_key)

        if recurring
          builder.recurringPaymentRequest do |payment_request|
            payment_request.initialPaymentReference do |payment_reference|
              payment_reference.merchantReference(merchant_reference)
            end
          end
        else
          builder.payment do |payment|
            payment.paymentMethod(payment_method)

            case payment_method
            when PaymentMethod::IDEAL
              payment.iDealPaymentInput do |input|
                input.issuerId(issuer_id)
              end
            when PaymentMethod::SEPA_DIRECT_DEBIT
              payment.directDebitPaymentInput do |input|
                input.holderName(account_name)
                input.iban(account_iban)
                input.bic(account_bic) if account_bic
              end
            else
              raise ArgumentError, "Payment method not supported: #{payment_method}"
            end
          end
        end
      end

      private

      def order_key
        options.fetch(:order_key)
      end

      def payment_method
        options.fetch(:payment_method)
      end

      def issuer_id
        options.fetch(:issuer_id)
      end

      def account_name
        options.fetch(:account_name)
      end

      def account_iban
        options.fetch(:account_iban)
      end

      def account_bic
        options[:account_bic]
      end

      def recurring
        options[:recurring]
      end

      def merchant_reference
        recurring[:merchant_reference]
      end
    end

    # Retrieve additional status information of an Order.
    class ExtendedStatusRequest < Request
      def build_request(builder)
        builder.paymentOrderKey(order_key)
      end

      private

      def order_key
        options.fetch(:order_key)
      end
    end
  end
end
