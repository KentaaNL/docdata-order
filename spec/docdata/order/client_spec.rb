# frozen_string_literal: true

require "spec_helper"

describe Docdata::Order::Client do
  subject(:client) { Docdata::Order::Client.new("12345", "12345") }

  before do
    wsdl = File.read("spec/fixtures/wsdl.xml")
    stub_request(:get, "https://secure.docdatapayments.com/ps/services/paymentservice/1_3?wsdl").to_return(status: 200, body: wsdl)
  end

  describe '#create' do
    it 'raises an exception when parameters are missing' do
      expect {
        client.create(amount: "10")
      }.to raise_error(KeyError)
    end

    it 'raises an exception when HTTPError' do
      stub_request(:get, "https://secure.docdatapayments.com/ps/services/paymentservice/1_3?wsdl").to_return(status: 502, body: "Bad Gateway", headers: {})

      expect {
        client.create(
          amount: "10",
          order_reference: SecureRandom.hex,
          description: "Test order",
          profile: "foobar",
          shopper: {
            first_name: "John",
            last_name: "Doe",
            email: "john.doe@example.com",
            language: "en",
            gender: Docdata::Order::Gender::MALE
          },
          address: {
            street: "Mainstreet",
            house_number: "42",
            postal_code: "1234AA",
            city: "Big city",
            country: "NL"
          }
        )
      }.to raise_error(Docdata::Order::ApiException)
    end

    it 'successfully creates an order' do
      data = File.read("spec/fixtures/responses/create_success.xml")
      stub_request(:post, "https://secure.docdatapayments.com/ps/services/paymentservice/1_3").to_return(status: 200, body: data)

      response = client.create(
        amount: "10",
        order_reference: SecureRandom.hex,
        description: "Test order",
        profile: "foobar",
        shopper: {
          first_name: "John",
          last_name: "Doe",
          email: "john.doe@example.com",
          language: "en",
          gender: Docdata::Order::Gender::MALE
        },
        address: {
          street: "Mainstreet",
          house_number: "42",
          postal_code: "1234AA",
          city: "Big city",
          country: "NL"
        }
      )

      expect(response.success?).to be true
      expect(response.error?).to be false
      expect(response.error_code).to be nil
      expect(response.error_message).to be nil

      expect(response.order_key).to eq("098F6BCD4621D373CADE4E832627B4F6")
    end

    it 'returns an error when creating an order fails' do
      data = File.read("spec/fixtures/responses/create_error.xml")
      stub_request(:post, "https://secure.docdatapayments.com/ps/services/paymentservice/1_3").to_return(status: 200, body: data)

      response = client.create(
        amount: "10",
        order_reference: SecureRandom.hex,
        description: "Test order",
        profile: "foobar",
        shopper: {
          first_name: "John",
          last_name: "Doe",
          email: "john.doe@example.com",
          language: "en",
          gender: Docdata::Order::Gender::MALE
        },
        address: {
          street: "Mainstreet",
          house_number: "42",
          postal_code: "1234AA",
          city: "Big city",
          country: "NL"
        }
      )

      expect(response.success?).to be false
      expect(response.error?).to be true
      expect(response.error_code).to eq("REQUEST_DATA_INCORRECT")
      expect(response.error_message).to eq("Merchant order reference is not unique.")
    end
  end

  describe '#start' do
    it 'raises an exception when parameters are missing' do
      expect {
        client.start(order_key: "098F6BCD4621D373CADE4E832627B4F6")
      }.to raise_error(KeyError)
    end

    it 'successfully starts an order' do
      data = File.read("spec/fixtures/responses/start_success.xml")
      stub_request(:post, "https://secure.docdatapayments.com/ps/services/paymentservice/1_3").to_return(status: 200, body: data)

      response = client.start(
        order_key: "098F6BCD4621D373CADE4E832627B4F6",
        payment_method: Docdata::Order::PaymentMethod::SEPA_DIRECT_DEBIT,
        consumer_name: "Onderheuvel",
        consumer_iban: "NL44RABO0123456789"
      )

      expect(response.success?).to be true
      expect(response.error?).to be false
      expect(response.error_code).to be nil
      expect(response.error_message).to be nil
    end

    it 'returns an error starting an order fails' do
      data = File.read("spec/fixtures/responses/start_error.xml")
      stub_request(:post, "https://secure.docdatapayments.com/ps/services/paymentservice/1_3").to_return(status: 200, body: data)

      response = client.start(
        order_key: "098F6BCD4621D373CADE4E832627B4F6",
        payment_method: Docdata::Order::PaymentMethod::SEPA_DIRECT_DEBIT,
        consumer_name: "Onderheuvel",
        consumer_iban: "NL44RABO0123456789"
      )

      expect(response.success?).to be false
      expect(response.error?).to be true
      expect(response.error_code).to eq("REQUEST_DATA_INCORRECT")
      expect(response.error_message).to eq("Order could not be found with the given key.")
    end
  end

  describe '#status' do
    it 'raises an exception when parameters are missing' do
      expect {
        client.status
      }.to raise_error(KeyError)
    end

    it 'successfully retrieves the status of an order' do
      data = File.read("spec/fixtures/responses/status_success_without_payment.xml")
      stub_request(:post, "https://secure.docdatapayments.com/ps/services/paymentservice/1_3").to_return(status: 200, body: data)

      response = client.status(order_key: "098F6BCD4621D373CADE4E832627B4F6")

      expect(response.success?).to be true
      expect(response.error?).to be false
      expect(response.error_code).to be nil
      expect(response.error_message).to be nil

      expect(response.paid?).to be false
      expect(response.refunded?).to be false
      expect(response.charged_back?).to be false
      expect(response.reversed?).to be false
      expect(response.cancelled?).to be false
      expect(response.started?).to be true
    end

    it 'returns an error when retrieving the status fails' do
      data = File.read("spec/fixtures/responses/status_error.xml")
      stub_request(:post, "https://secure.docdatapayments.com/ps/services/paymentservice/1_3").to_return(status: 200, body: data)

      response = client.status(order_key: "098F6BCD4621D373CADE4E832627B4F6")

      expect(response.success?).to be false
      expect(response.error?).to be true
      expect(response.error_code).to eq("REQUEST_DATA_INCORRECT")
      expect(response.error_message).to eq("Order could not be found with the given key.")
    end
  end

  describe '#refund' do
    it 'raises an exception when parameters are missing' do
      expect {
        client.refund
      }.to raise_error(KeyError)
    end

    it 'successfully refunds a payment' do
      data = File.read("spec/fixtures/responses/refund_success.xml")
      stub_request(:post, "https://secure.docdatapayments.com/ps/services/paymentservice/1_3").to_return(status: 200, body: data)

      response = client.refund(payment_id: "12345678")

      expect(response.success?).to be true
      expect(response.error?).to be false
      expect(response.error_code).to be nil
      expect(response.error_message).to be nil
    end

    it 'returns an error when refunding a payment fails' do
      data = File.read("spec/fixtures/responses/refund_error.xml")
      stub_request(:post, "https://secure.docdatapayments.com/ps/services/paymentservice/1_3").to_return(status: 200, body: data)

      response = client.refund(payment_id: "12345678")

      expect(response.success?).to be false
      expect(response.error?).to be true
      expect(response.error_code).to eq("REQUEST_DATA_INCORRECT")
      expect(response.error_message).to eq("No amount captured available to refund.")
    end
  end

  describe '#payment_methods' do
    it 'raises an exception when parameters are missing' do
      expect {
        client.payment_methods
      }.to raise_error(KeyError)
    end

    it 'successfully retrieves the payment methods of an order' do
      data = File.read("spec/fixtures/responses/payment_methods_success.xml")
      stub_request(:post, "https://secure.docdatapayments.com/ps/services/paymentservice/1_3").to_return(status: 200, body: data)

      response = client.payment_methods(order_key: "098F6BCD4621D373CADE4E832627B4F6")

      expect(response.success?).to be true
      expect(response.error?).to be false
      expect(response.error_code).to be nil
      expect(response.error_message).to be nil

      expect(response.payment_methods).to be_a(Array)
    end

    it 'returns an error when retrieving the payment methods fails' do
      data = File.read("spec/fixtures/responses/payment_methods_error.xml")
      stub_request(:post, "https://secure.docdatapayments.com/ps/services/paymentservice/1_3").to_return(status: 200, body: data)

      response = client.payment_methods(order_key: "098F6BCD4621D373CADE4E832627B4F6")

      expect(response.success?).to be false
      expect(response.error?).to be true
      expect(response.error_code).to eq("REQUEST_DATA_INCORRECT")
      expect(response.error_message).to eq("Order could not be found with the given key.")
    end
  end
end
