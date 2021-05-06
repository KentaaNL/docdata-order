# frozen_string_literal: true

require "spec_helper"

describe Docdata::Order::Response do
  describe "create" do
    subject(:response) do
      http = OpenStruct.new(body: xml)
      response = Savon::Response.new(http, Savon::GlobalOptions.new, Savon::LocalOptions.new)
      Docdata::Order::CreateResponse.new(options, response)
    end

    context "with payment method iDEAL" do
      let(:options) { { merchant: { name: "12345" }, shopper: { language: "nl" }, payment_method: Docdata::Order::PaymentMethod::IDEAL, issuer_id: "ABNANL2A" } }
      let(:xml) { File.read("spec/fixtures/responses/create_success.xml") }

      it 'returns the order key' do
        expect(response.order_key).to eq("098F6BCD4621D373CADE4E832627B4F6")
      end

      it 'returns the redirect URL' do
        expect(response.redirect_url).to eq("https://secure.docdatapayments.com/ps/menu?command=show_payment_cluster&merchant_name=12345&client_language=nl&payment_cluster_key=098F6BCD4621D373CADE4E832627B4F6&default_pm=IDEAL&default_act=true&ideal_issuer_id=ABNANL2A")
      end
    end

    context "with payment method Visa" do
      let(:options) { { merchant: { name: "12345" }, shopper: { language: "nl" }, payment_method: Docdata::Order::PaymentMethod::VISA } }
      let(:xml) { File.read("spec/fixtures/responses/create_success.xml") }

      it 'returns the order key' do
        expect(response.order_key).to eq("098F6BCD4621D373CADE4E832627B4F6")
      end

      it 'returns the redirect URL' do
        expect(response.redirect_url).to eq("https://secure.docdatapayments.com/ps/menu?command=show_payment_cluster&merchant_name=12345&client_language=nl&payment_cluster_key=098F6BCD4621D373CADE4E832627B4F6&default_pm=VISA")
      end
    end

    context "with payment method MasterCard" do
      let(:options) { { merchant: { name: "12345" }, shopper: { language: "nl" }, payment_method: Docdata::Order::PaymentMethod::MASTER_CARD } }
      let(:xml) { File.read("spec/fixtures/responses/create_success.xml") }

      it 'returns the order key' do
        expect(response.order_key).to eq("098F6BCD4621D373CADE4E832627B4F6")
      end

      it 'returns the redirect URL' do
        expect(response.redirect_url).to eq("https://secure.docdatapayments.com/ps/menu?command=show_payment_cluster&merchant_name=12345&client_language=nl&payment_cluster_key=098F6BCD4621D373CADE4E832627B4F6&default_pm=MASTERCARD")
      end
    end

    context "with payment method PayPal" do
      let(:options) { { merchant: { name: "12345" }, shopper: { language: "nl" }, payment_method: Docdata::Order::PaymentMethod::PAYPAL } }
      let(:xml) { File.read("spec/fixtures/responses/create_success.xml") }

      it 'returns the order key' do
        expect(response.order_key).to eq("098F6BCD4621D373CADE4E832627B4F6")
      end

      it 'returns the redirect URL' do
        expect(response.redirect_url).to eq("https://secure.docdatapayments.com/ps/menu?command=show_payment_cluster&merchant_name=12345&client_language=nl&payment_cluster_key=098F6BCD4621D373CADE4E832627B4F6&default_pm=PAYPAL_EXPRESS_CHECKOUT&default_act=true")
      end
    end
  end

  describe "start" do
    subject(:response) do
      http = OpenStruct.new(body: xml)
      response = Savon::Response.new(http, Savon::GlobalOptions.new, Savon::LocalOptions.new)
      Docdata::Order::StartResponse.new({}, response)
    end

    let(:xml) { File.read("spec/fixtures/responses/start_success.xml") }

    it 'returns the payment ID' do
      expect(response.payment_id).to eq("12345678")
    end
  end

  describe "status" do
    subject(:response) do
      http = OpenStruct.new(body: xml)
      response = Savon::Response.new(http, Savon::GlobalOptions.new, Savon::LocalOptions.new)
      Docdata::Order::ExtendedStatusResponse.new({}, response)
    end

    context "with cancelled iDEAL order" do
      let(:xml) { File.read("spec/fixtures/responses/status_success_ideal_cancelled.xml") }

      it 'returns the registered amount' do
        expect(response.total_registered).to eq(1.0)
      end

      it 'returns the payment ID' do
        expect(response.payment_id).to eq("12345678")
      end

      it 'returns the payment method' do
        expect(response.payment_method).to eq(Docdata::Order::PaymentMethod::IDEAL)
      end

      it 'returns the payment status' do
        expect(response.paid?).to be false
        expect(response.refunded?).to be false
        expect(response.charged_back?).to be false
        expect(response.reversed?).to be false
        expect(response.cancelled?).to be true
        expect(response.started?).to be false
      end

      it 'returns the IBAN' do
        expect(response.account_name).to eq("Onderheuvel")
        expect(response.account_iban).to eq("NL44RABO0123456789")
        expect(response.account_bic).to eq("RABONL2U")
      end
    end

    context "with paid iDEAL order" do
      let(:xml) { File.read("spec/fixtures/responses/status_success_ideal_paid.xml") }

      it 'returns the registered amount' do
        expect(response.total_registered).to eq(1.0)
      end

      it 'returns the acquirer approved amount' do
        expect(response.total_acquirer_approved).to eq(1.0)
      end

      it 'returns the captured amount' do
        expect(response.total_captured).to eq(1.0)
      end

      it 'returns the payment ID' do
        expect(response.payment_id).to eq("12345678")
      end

      it 'returns the payment method' do
        expect(response.payment_method).to eq(Docdata::Order::PaymentMethod::IDEAL)
      end

      it 'returns the payment status' do
        expect(response.paid?).to be true
        expect(response.refunded?).to be false
        expect(response.charged_back?).to be false
        expect(response.reversed?).to be false
        expect(response.cancelled?).to be false
        expect(response.started?).to be false
      end

      it 'returns the IBAN' do
        expect(response.account_name).to eq("Onderheuvel")
        expect(response.account_iban).to eq("NL44RABO0123456789")
        expect(response.account_bic).to eq("RABONL2U")
      end
    end

    context "with paid AMEX order" do
      let(:xml) { File.read("spec/fixtures/responses/status_success_amex_paid.xml") }

      it 'returns the registered amount' do
        expect(response.total_registered).to eq(1.0)
      end

      it 'returns the acquirer approved amount' do
        expect(response.total_acquirer_approved).to eq(1.0)
      end

      it 'returns the payment ID' do
        expect(response.payment_id).to eq("12345678")
      end

      it 'returns the payment method' do
        expect(response.payment_method).to eq(Docdata::Order::PaymentMethod::AMERICAN_EXPRESS)
      end

      it 'returns the payment status' do
        expect(response.paid?).to be true
        expect(response.refunded?).to be false
        expect(response.charged_back?).to be false
        expect(response.reversed?).to be false
        expect(response.cancelled?).to be false
        expect(response.started?).to be false
      end
    end

    context "with pending SEPA direct debit order" do
      let(:xml) { File.read("spec/fixtures/responses/status_success_sepa_dd_pending.xml") }

      it 'returns the registered amount' do
        expect(response.total_registered).to eq(1.0)
      end

      it 'returns the acquirer pending amount' do
        expect(response.total_acquirer_pending).to eq(1.0)
      end

      it 'returns the payment ID' do
        expect(response.payment_id).to eq("12345678")
      end

      it 'returns the payment method' do
        expect(response.payment_method).to eq(Docdata::Order::PaymentMethod::SEPA_DIRECT_DEBIT)
      end

      it 'returns the payment status' do
        expect(response.paid?).to be false
        expect(response.refunded?).to be false
        expect(response.charged_back?).to be false
        expect(response.reversed?).to be false
        expect(response.cancelled?).to be false
        expect(response.started?).to be true
      end

      it 'returns the IBAN' do
        expect(response.account_name).to be nil
        expect(response.account_iban).to eq("NL44RABO0123456789")
        expect(response.account_bic).to be nil
      end

      it 'returns the mandate number' do
        expect(response.mandate_number).to eq("ddps-123456789012345678")
      end
    end

    context "with order that has no payment" do
      let(:xml) { File.read("spec/fixtures/responses/status_success_without_payment.xml") }

      it 'returns the registered amount' do
        expect(response.total_registered).to eq(1.0)
      end

      it 'returns no payment ID' do
        expect(response.payment_id).to be nil
      end

      it 'returns no payment method' do
        expect(response.payment_method).to be nil
      end

      it 'returns the payment status' do
        expect(response.paid?).to be false
        expect(response.refunded?).to be false
        expect(response.charged_back?).to be false
        expect(response.reversed?).to be false
        expect(response.cancelled?).to be false
        expect(response.started?).to be true
      end

      it 'returns no IBAN' do
        expect(response.account_name).to be nil
        expect(response.account_iban).to be nil
        expect(response.account_bic).to be nil
      end
    end
  end

  describe "payment_methods" do
    subject(:response) do
      http = OpenStruct.new(body: xml)
      response = Savon::Response.new(http, Savon::GlobalOptions.new, Savon::LocalOptions.new)
      Docdata::Order::ListPaymentMethodsResponse.new({}, response)
    end

    let(:xml) { File.read("spec/fixtures/responses/payment_methods_success.xml") }

    it 'returns an array with payment methods' do
      expect(response.payment_methods).to be_a(Array)
      expect(response.payment_methods.count).to eq(6)
      expect(response.payment_methods.first).to be_a(Docdata::Order::PaymentMethod)
    end

    it 'returns the issuers for iDEAL' do
      ideal = response.payment_methods.find { |method| method.to_s == Docdata::Order::PaymentMethod::IDEAL }
      expect(ideal).to be_a(Docdata::Order::PaymentMethod)
      expect(ideal.issuers).to eq(
        "ABNANL2A" => "ABN Amro Bank",
        "ASNBNL21" => "ASN Bank",
        "BUNQNL2A" => "bunq",
        "FVLBNL22" => "Van Lanschot Bankiers",
        "HANDNL2A" => "Handelsbanken",
        "INGBNL2A" => "ING Bank",
        "KNABNL2H" => "Knab",
        "KREDBE22" => "KBC",
        "MOYONL21" => "Moneyou",
        "RABONL2U" => "Rabobank",
        "RBRBNL21" => "RegioBank",
        "SNSBNL2A" => "SNS Bank",
        "TRIONL2U" => "Triodos Bank"
      )
    end
  end
end
