# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Docdata::Order::Request do
  describe 'create' do
    it 'creates a XML message using all available parameters' do
      request = Docdata::Order::CreateRequest.new(
        merchant: {
          name: 'name',
          password: 'password'
        },
        amount: '10',
        currency: 'USD',
        order_reference: '12345',
        description: 'Test order',
        profile: 'foobar',
        shopper: {
          id: '12345',
          first_name: 'John',
          infix: 'from',
          last_name: 'Doe',
          email: 'john.doe@example.com',
          language: 'en',
          gender: Docdata::Order::Gender::MALE,
          ip_address: '127.0.0.1'
        },
        address: {
          street: 'Mainstreet',
          house_number: '42',
          postal_code: '1234AA',
          city: 'Big city',
          country: 'NL'
        },
        payment_method: Docdata::Order::PaymentMethod::IDEAL,
        return_url: 'http://yourwebshop.nl/payment_return'
      )

      expect(request.to_s).to eq(%(<merchant name="name" password="password"/><merchantOrderReference>12345</merchantOrderReference><paymentPreferences><profile>foobar</profile><numberOfDaysToPay>14</numberOfDaysToPay></paymentPreferences><shopper id="12345"><name><first>John</first><middle>from</middle><last>Doe</last></name><email>john.doe@example.com</email><language code="en"/><gender>M</gender><ipAddress>127.0.0.1</ipAddress></shopper><totalGrossAmount currency="USD">1000</totalGrossAmount><billTo><name><first>John</first><middle>from</middle><last>Doe</last></name><address><street>Mainstreet</street><houseNumber>42</houseNumber><postalCode>1234AA</postalCode><city>Big city</city><country code="NL"/></address></billTo><description>Test order</description><receiptText>Test order</receiptText><integrationInfo><webshopPlugin>docdata-order</webshopPlugin><webshopPluginVersion>#{Docdata::Order::VERSION}</webshopPluginVersion><integratorName>Kentaa</integratorName><programmingLanguage>Ruby #{RUBY_VERSION}</programmingLanguage><operatingSystem>#{RUBY_PLATFORM}</operatingSystem><ddpXsdVersion>#{Docdata::Order::Client::DDP_VERSION}</ddpXsdVersion></integrationInfo>))
    end

    it 'creates a XML message with an initial payment request' do
      request = Docdata::Order::CreateRequest.new(
        merchant: {
          name: 'name',
          password: 'password'
        },
        amount: '10',
        currency: 'USD',
        order_reference: '12345',
        description: 'Test order',
        profile: 'foobar',
        shopper: {
          id: '12345',
          first_name: 'John',
          infix: 'from',
          last_name: 'Doe',
          email: 'john.doe@example.com',
          language: 'en',
          gender: Docdata::Order::Gender::MALE,
          ip_address: '127.0.0.1'
        },
        address: {
          street: 'Mainstreet',
          house_number: '42',
          postal_code: '1234AA',
          city: 'Big city',
          country: 'NL'
        },
        payment_method: Docdata::Order::PaymentMethod::IDEAL,
        return_url: 'http://yourwebshop.nl/payment_return',
        initial: {
          merchant_reference: '12345'
        }
      )

      expect(request.to_s).to eq(%(<merchant name="name" password="password"/><merchantOrderReference>12345</merchantOrderReference><paymentPreferences><profile>foobar</profile><numberOfDaysToPay>14</numberOfDaysToPay></paymentPreferences><shopper id="12345"><name><first>John</first><middle>from</middle><last>Doe</last></name><email>john.doe@example.com</email><language code="en"/><gender>M</gender><ipAddress>127.0.0.1</ipAddress></shopper><totalGrossAmount currency="USD">1000</totalGrossAmount><billTo><name><first>John</first><middle>from</middle><last>Doe</last></name><address><street>Mainstreet</street><houseNumber>42</houseNumber><postalCode>1234AA</postalCode><city>Big city</city><country code="NL"/></address></billTo><description>Test order</description><receiptText>Test order</receiptText><paymentRequest><initialPaymentReference><merchantReference>12345</merchantReference></initialPaymentReference></paymentRequest><integrationInfo><webshopPlugin>docdata-order</webshopPlugin><webshopPluginVersion>#{Docdata::Order::VERSION}</webshopPluginVersion><integratorName>Kentaa</integratorName><programmingLanguage>Ruby #{RUBY_VERSION}</programmingLanguage><operatingSystem>#{RUBY_PLATFORM}</operatingSystem><ddpXsdVersion>#{Docdata::Order::Client::DDP_VERSION}</ddpXsdVersion></integrationInfo>))
    end

    it 'creates a XML message with a subject merchant fee' do
      request = Docdata::Order::CreateRequest.new(
        merchant: {
          name: 'name',
          password: 'password'
        },
        amount: '10',
        currency: 'USD',
        order_reference: '12345',
        description: 'Test order',
        profile: 'foobar',
        shopper: {
          id: '12345',
          first_name: 'John',
          infix: 'from',
          last_name: 'Doe',
          email: 'john.doe@example.com',
          language: 'en',
          gender: Docdata::Order::Gender::MALE,
          ip_address: '127.0.0.1'
        },
        address: {
          street: 'Mainstreet',
          house_number: '42',
          postal_code: '1234AA',
          city: 'Big city',
          country: 'NL'
        },
        payment_method: Docdata::Order::PaymentMethod::IDEAL,
        return_url: 'http://yourwebshop.nl/payment_return',
        subject_merchant: {
          name: 'sub',
          token: '12345',
          fee: {
            amount: '2.50',
            currency: 'USD',
            description: 'fee description'
          }
        }
      )

      expect(request.to_s).to eq(%(<merchant name="name" password="password"><subjectMerchant name="sub" token="12345"><fee moment="FULLY_PAID"><amount currency="USD">250</amount><description>fee description</description></fee></subjectMerchant></merchant><merchantOrderReference>12345</merchantOrderReference><paymentPreferences><profile>foobar</profile><numberOfDaysToPay>14</numberOfDaysToPay></paymentPreferences><shopper id="12345"><name><first>John</first><middle>from</middle><last>Doe</last></name><email>john.doe@example.com</email><language code="en"/><gender>M</gender><ipAddress>127.0.0.1</ipAddress></shopper><totalGrossAmount currency="USD">1000</totalGrossAmount><billTo><name><first>John</first><middle>from</middle><last>Doe</last></name><address><street>Mainstreet</street><houseNumber>42</houseNumber><postalCode>1234AA</postalCode><city>Big city</city><country code="NL"/></address></billTo><description>Test order</description><receiptText>Test order</receiptText><integrationInfo><webshopPlugin>docdata-order</webshopPlugin><webshopPluginVersion>#{Docdata::Order::VERSION}</webshopPluginVersion><integratorName>Kentaa</integratorName><programmingLanguage>Ruby #{RUBY_VERSION}</programmingLanguage><operatingSystem>#{RUBY_PLATFORM}</operatingSystem><ddpXsdVersion>#{Docdata::Order::Client::DDP_VERSION}</ddpXsdVersion></integrationInfo>))
    end
  end

  describe 'start' do
    context 'with payment method iDEAL' do
      it 'creates a start payment request XML message' do
        request = Docdata::Order::StartRequest.new(
          merchant: {
            name: 'name',
            password: 'password'
          },
          order_key: '12345',
          payment_method: Docdata::Order::PaymentMethod::IDEAL
        )

        expect(request.to_s).to eq(%(<merchant name="name" password="password"/><paymentOrderKey>12345</paymentOrderKey><payment><paymentMethod>IDEAL</paymentMethod></payment><integrationInfo><webshopPlugin>docdata-order</webshopPlugin><webshopPluginVersion>#{Docdata::Order::VERSION}</webshopPluginVersion><integratorName>Kentaa</integratorName><programmingLanguage>Ruby #{RUBY_VERSION}</programmingLanguage><operatingSystem>#{RUBY_PLATFORM}</operatingSystem><ddpXsdVersion>#{Docdata::Order::Client::DDP_VERSION}</ddpXsdVersion></integrationInfo>))
      end
    end

    context 'with payment method iDEAL and issuer ID' do
      it 'creates a start payment request XML message' do
        request = Docdata::Order::StartRequest.new(
          merchant: {
            name: 'name',
            password: 'password'
          },
          order_key: '12345',
          payment_method: Docdata::Order::PaymentMethod::IDEAL,
          issuer_id: 'ABNANL2A'
        )

        expect(request.to_s).to eq(%(<merchant name="name" password="password"/><paymentOrderKey>12345</paymentOrderKey><payment><paymentMethod>IDEAL</paymentMethod><iDealPaymentInput><issuerId>ABNANL2A</issuerId></iDealPaymentInput></payment><integrationInfo><webshopPlugin>docdata-order</webshopPlugin><webshopPluginVersion>#{Docdata::Order::VERSION}</webshopPluginVersion><integratorName>Kentaa</integratorName><programmingLanguage>Ruby #{RUBY_VERSION}</programmingLanguage><operatingSystem>#{RUBY_PLATFORM}</operatingSystem><ddpXsdVersion>#{Docdata::Order::Client::DDP_VERSION}</ddpXsdVersion></integrationInfo>))
      end
    end

    context 'with payment method SEPA' do
      it 'creates a start payment request XML message' do
        request = Docdata::Order::StartRequest.new(
          merchant: {
            name: 'name',
            password: 'password'
          },
          order_key: '12345',
          payment_method: Docdata::Order::PaymentMethod::SEPA_DIRECT_DEBIT,
          consumer_name: 'Onderheuvel',
          consumer_iban: 'NL44RABO0123456789',
          consumer_bic: 'RABONL2U'
        )

        expect(request.to_s).to eq(%(<merchant name="name" password="password"/><paymentOrderKey>12345</paymentOrderKey><payment><paymentMethod>SEPA_DIRECT_DEBIT</paymentMethod><directDebitPaymentInput><holderName>Onderheuvel</holderName><iban>NL44RABO0123456789</iban><bic>RABONL2U</bic></directDebitPaymentInput></payment><integrationInfo><webshopPlugin>docdata-order</webshopPlugin><webshopPluginVersion>#{Docdata::Order::VERSION}</webshopPluginVersion><integratorName>Kentaa</integratorName><programmingLanguage>Ruby #{RUBY_VERSION}</programmingLanguage><operatingSystem>#{RUBY_PLATFORM}</operatingSystem><ddpXsdVersion>#{Docdata::Order::Client::DDP_VERSION}</ddpXsdVersion></integrationInfo>))
      end
    end

    context 'with a start recurring payment request' do
      it 'creates a start payment request XML message' do
        request = Docdata::Order::StartRequest.new(
          merchant: {
            name: 'name',
            password: 'password'
          },
          order_key: '12345',
          recurring: {
            merchant_reference: '12345'
          }
        )

        expect(request.to_s).to eq(%(<merchant name="name" password="password"/><paymentOrderKey>12345</paymentOrderKey><recurringPaymentRequest><initialPaymentReference><merchantReference>12345</merchantReference></initialPaymentReference></recurringPaymentRequest><integrationInfo><webshopPlugin>docdata-order</webshopPlugin><webshopPluginVersion>#{Docdata::Order::VERSION}</webshopPluginVersion><integratorName>Kentaa</integratorName><programmingLanguage>Ruby #{RUBY_VERSION}</programmingLanguage><operatingSystem>#{RUBY_PLATFORM}</operatingSystem><ddpXsdVersion>#{Docdata::Order::Client::DDP_VERSION}</ddpXsdVersion></integrationInfo>))
      end
    end
  end

  describe 'status' do
    it 'creates a XML message with a status request' do
      request = Docdata::Order::ExtendedStatusRequest.new(
        merchant: {
          name: 'name',
          password: 'password'
        },
        order_key: '12345'
      )

      expect(request.to_s).to eq(%(<merchant name="name" password="password"/><paymentOrderKey>12345</paymentOrderKey><integrationInfo><webshopPlugin>docdata-order</webshopPlugin><webshopPluginVersion>#{Docdata::Order::VERSION}</webshopPluginVersion><integratorName>Kentaa</integratorName><programmingLanguage>Ruby #{RUBY_VERSION}</programmingLanguage><operatingSystem>#{RUBY_PLATFORM}</operatingSystem><ddpXsdVersion>#{Docdata::Order::Client::DDP_VERSION}</ddpXsdVersion></integrationInfo>))
    end
  end

  describe 'refund' do
    it 'creates a XML message with a refund request' do
      request = Docdata::Order::RefundRequest.new(
        merchant: {
          name: 'name',
          password: 'password'
        },
        payment_id: '12345',
        refund_reference: 'ABCDEF1234567890',
        amount: '10',
        currency: 'USD'
      )

      expect(request.to_s).to eq(%(<merchant name="name" password="password"/><paymentId>12345</paymentId><merchantRefundReference>ABCDEF1234567890</merchantRefundReference><amount currency="USD">1000</amount><integrationInfo><webshopPlugin>docdata-order</webshopPlugin><webshopPluginVersion>#{Docdata::Order::VERSION}</webshopPluginVersion><integratorName>Kentaa</integratorName><programmingLanguage>Ruby #{RUBY_VERSION}</programmingLanguage><operatingSystem>#{RUBY_PLATFORM}</operatingSystem><ddpXsdVersion>#{Docdata::Order::Client::DDP_VERSION}</ddpXsdVersion></integrationInfo>))
    end
  end

  describe 'payment_methods' do
    it 'creates a XML message with a list payment methods request' do
      request = Docdata::Order::ListPaymentMethodsRequest.new(
        merchant: {
          name: 'name',
          password: 'password'
        },
        order_key: '12345'
      )

      expect(request.to_s).to eq(%(<merchant name="name" password="password"/><paymentOrderKey>12345</paymentOrderKey><integrationInfo><webshopPlugin>docdata-order</webshopPlugin><webshopPluginVersion>#{Docdata::Order::VERSION}</webshopPluginVersion><integratorName>Kentaa</integratorName><programmingLanguage>Ruby #{RUBY_VERSION}</programmingLanguage><operatingSystem>#{RUBY_PLATFORM}</operatingSystem><ddpXsdVersion>#{Docdata::Order::Client::DDP_VERSION}</ddpXsdVersion></integrationInfo>))
    end
  end
end
