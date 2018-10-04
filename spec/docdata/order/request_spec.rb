# frozen_string_literal: true

require "spec_helper"

describe Docdata::Order::Request do
  describe "create" do
    it "creates a XML message using all available parameters" do
      request = Docdata::Order::CreateRequest.new(
        merchant: {
          name: "name",
          password: "password"
        },
        amount: BigDecimal("10"),
        currency: "USD",
        order_reference: "12345",
        description: "Test order",
        profile: "foobar",
        shopper: {
          id: "12345",
          first_name: "John",
          infix: "from",
          last_name: "Doe",
          email: "john.doe@example.com",
          language: "en",
          gender: Docdata::Order::Gender::MALE,
          ip_address: "127.0.0.1"
        },
        address: {
          street: "Mainstreet",
          house_number: "42",
          postal_code: "1234AA",
          city: "Big city",
          country: "NL"
        },
        payment_method: Docdata::Order::PaymentMethod::IDEAL,
        issuer_id: Docdata::Order::Ideal::ISSUERS.first[0],
        return_url: "http://yourwebshop.nl/payment_return"
      )

      expect(request.to_s).to eq(%(<merchant name="name" password="password"/><merchantOrderReference>12345</merchantOrderReference><paymentPreferences><profile>foobar</profile><numberOfDaysToPay>14</numberOfDaysToPay></paymentPreferences><shopper id="12345"><name><first>John</first><middle>from</middle><last>Doe</last></name><email>john.doe@example.com</email><language code="en"/><gender>M</gender><ipAddress>127.0.0.1</ipAddress></shopper><totalGrossAmount currency="USD">1000</totalGrossAmount><billTo><name><first>John</first><middle>from</middle><last>Doe</last></name><address><street>Mainstreet</street><houseNumber>42</houseNumber><postalCode>1234AA</postalCode><city>Big city</city><country code="NL"/></address></billTo><description>Test order</description><receiptText>Test order</receiptText><integrationInfo><webshopPlugin>docdata-order</webshopPlugin><webshopPluginVersion>#{Docdata::Order::VERSION}</webshopPluginVersion><integratorName>Kentaa</integratorName><programmingLanguage>Ruby #{RUBY_VERSION}</programmingLanguage><operatingSystem>#{RUBY_PLATFORM}</operatingSystem><ddpXsdVersion>#{Docdata::Order::Client::DDP_VERSION}</ddpXsdVersion></integrationInfo>))
    end
  end

  describe "start" do
    it "creates a XML message using all available parameters" do
      request = Docdata::Order::StartRequest.new(
        merchant: {
          name: "name",
          password: "password"
        },
        order_key: "12345",
        payment_method: Docdata::Order::PaymentMethod::SEPA_DIRECT_DEBIT,
        account_name: "Onderheuvel",
        account_iban: "NL44RABO0123456789",
        account_bic: "RABONL2U"
      )

      expect(request.to_s).to eq(%(<merchant name="name" password="password"/><paymentOrderKey>12345</paymentOrderKey><payment><paymentMethod>SEPA_DIRECT_DEBIT</paymentMethod><directDebitPaymentInput><holderName>Onderheuvel</holderName><iban>NL44RABO0123456789</iban><bic>RABONL2U</bic></directDebitPaymentInput></payment><integrationInfo><webshopPlugin>docdata-order</webshopPlugin><webshopPluginVersion>#{Docdata::Order::VERSION}</webshopPluginVersion><integratorName>Kentaa</integratorName><programmingLanguage>Ruby #{RUBY_VERSION}</programmingLanguage><operatingSystem>#{RUBY_PLATFORM}</operatingSystem><ddpXsdVersion>#{Docdata::Order::Client::DDP_VERSION}</ddpXsdVersion></integrationInfo>))
    end
  end

  describe "status" do
    it "creates a XML message using all available parameters" do
      request = Docdata::Order::ExtendedStatusRequest.new(
        merchant: {
          name: "name",
          password: "password"
        },
        order_key: "12345"
      )

      expect(request.to_s).to eq(%(<merchant name="name" password="password"/><paymentOrderKey>12345</paymentOrderKey><integrationInfo><webshopPlugin>docdata-order</webshopPlugin><webshopPluginVersion>#{Docdata::Order::VERSION}</webshopPluginVersion><integratorName>Kentaa</integratorName><programmingLanguage>Ruby #{RUBY_VERSION}</programmingLanguage><operatingSystem>#{RUBY_PLATFORM}</operatingSystem><ddpXsdVersion>#{Docdata::Order::Client::DDP_VERSION}</ddpXsdVersion></integrationInfo>))
    end
  end
end
