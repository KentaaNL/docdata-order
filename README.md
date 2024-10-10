# Docdata::Order

[![Gem Version](https://badge.fury.io/rb/docdata-order.svg)](https://badge.fury.io/rb/docdata-order)
[![Build Status](https://github.com/KentaaNL/docdata-order/actions/workflows/test.yml/badge.svg)](https://github.com/KentaaNL/docdata-order/actions)
[![Code Climate](https://codeclimate.com/github/KentaaNL/docdata-order/badges/gpa.svg)](https://codeclimate.com/github/KentaaNL/docdata-order)

Docdata::Order is a Ruby client for the Docdata Order API version 1.3.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Initialization](#initialization)
    - [Subject merchant](#subject-merchant)
  - [Create an order](#create-an-order)
    - [Redirecting directly to the payment page](#redirecting-directly-to-the-payment-page)
    - [Initial payment request](#initial-payment-request)
  - [Start a payment order](#start-a-payment-order)
    - [Recurring payment request](#recurring-payment-request)
  - [Retrieve status of an order](#retrieve-status-of-an-order)
  - [Retrieve payment methods](#retrieve-payment-methods)
  - [Refund a payment](#refund-a-payment)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'docdata-order'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install docdata-order

## Usage

### Initialization

Create a Docdata Order client and configure it with your merchant name and password:

```ruby
client = Docdata::Order::Client.new("name", "password")
```

The client is configured to use the production environment by default. To use the Docdata test environment, add the parameter `test: true` when creating the client.

#### Subject merchant

If you want to use a merchant on whose behalf the requests should be executed (subject merchant), then you can add this to the parameters:

```ruby
client = Docdata::Order::Client.new("name", "password", subject_merchant: {
  name: "subname",
  token: "12345678"
})
```

### Create an order

Create a new order with the `create` method. You need to provide at least the following parameters to create the order:

```ruby
options = {
  amount: "12.50",
  order_reference: "12345",
  description: "Test order",
  profile: "profile",
  shopper: {
    first_name: "John",
    last_name: "Doe",
    email: "john.doe@example.com",
    language: "en",
    gender: Docdata::Order::Gender::MALE
  },
  address: {
    street: "Jansbuitensingel",
    house_number: "29",
    postal_code: "6811AD",
    city: "Arnhem",
    country: "NL"
  }
}

response = client.create(options)

if response.success?
  puts response.order_key
  puts response.redirect_url
else
  puts response.error_message
end
```

The `redirect_url` in the response will redirect the user to the Docdata Payment Menu (One Page Checkout).

#### Redirecting directly to the payment page

For some payment methods you can skip the Docdata One Page Checkout and redirect directly to the payment page of the specified payment method.
This works for the payment methods iDEAL, Sofort and PayPal.

```ruby
response = client.create(options.merge(
  payment_method: Docdata::Order::PaymentMethod::IDEAL,
  return_url: "http://yourwebshop.nl/payment_return"
))
```

#### Initial payment request

If you want to use this order to do recurring payments then you must first make an initial payment request and provide an unique merchant reference.
This reference should then be used when a making recurring payments.

```ruby
response = client.create(options.merge(
  initial: {
    merchant_reference: "12345"
  }
))
```

See [Recurring payment request](#recurring-payment-request) how to make recurring payment requests.

### Start a payment order

When the One Page Checkout is not used (i.e. WebDirect) then you need to use `start` to start a payment order.

```ruby
options = {
  order_key: "12345",
  payment_method: Docdata::Order::PaymentMethod::SEPA_DIRECT_DEBIT,
  consumer_name: "Onderheuvel",
  consumer_iban: "NL44RABO0123456789"
}

response = client.start(options)

if response.success?
  puts response.payment_id
else
  puts response.error_message
end
```

#### Recurring payment request

To start a recurring payment request, you need to provide the unique merchant reference, used in the initial payment request:

```ruby
response = client.start(options.merge(
  recurring: {
    merchant_reference: "12345"
  }
))
```

### Retrieve status of an order

To retrieve the status of an order, use `status` with the order key:

```ruby
response = client.status(order_key: "12345")

if response.success?
  puts response.paid?
else
  puts response.error_message
end
```

### Retrieve payment methods

When an order has been created, you can retrieve the available payment methods (including issuers) by using `payment_methods` with the order key:

```ruby
response = client.payment_methods(order_key: "12345")

if response.success?
  puts response.payment_methods
else
  puts response.error_message
end
```

### Refund a payment

To refund a payment, use `refund` with the payment ID:

```ruby
response = client.refund(payment_id: "12345")

if !response.success?
  puts response.error_message
end

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/KentaaNL/docdata-order.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
