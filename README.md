# Docdata::Order

[![Gem Version](https://badge.fury.io/rb/docdata-order.svg)](https://badge.fury.io/rb/docdata-order)
[![Build Status](https://travis-ci.org/KentaaNL/docdata-order.svg?branch=master)](https://travis-ci.org/KentaaNL/docdata-order)
[![Code Climate](https://codeclimate.com/github/KentaaNL/docdata-order/badges/gpa.svg)](https://codeclimate.com/github/KentaaNL/docdata-order)

Docdata::Order is a Ruby client for the Docdata Order API version 1.3.

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
order = Docdata::Order::Client.new("name", "password")
```

The client is configured in live mode by default. To put the client in test mode, use `test: true` as third parameter.

### Create an order

Create a new order with the `create` method. You need to provide the following parameters to create the order:

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

response = order.create(options)

if response.success?
  puts response.order_key
  puts response.redirect_url
else
  puts response.error_message
end
```

The `redirect_url` in the response will redirect the user to the Docdata Payment Menu (One Page Checkout).

To create an order and automatically redirect to the bank using iDEAL as payment method, use the parameters above including:

```ruby
response = order.create(options.merge(
  payment_method: Docdata::Order::PaymentMethod::IDEAL,
  issuer_id: Docdata::Order::Ideal::ISSUERS.first[0],
  return_url: "http://yourwebshop.nl/payment_return"
))
```

### Start a payment order

When using Webdirect, you can use `start` to start a payment order.

```ruby
options = {
  order_key: "12345",
  payment_method: Docdata::Order::PaymentMethod::SEPA_DIRECT_DEBIT,
  account_name: "Onderheuvel",
  account_iban: "NL44RABO0123456789"
}

response = order.start(options)

if response.success?
  puts response.payment_id
else
  puts response.error_message
end
```

### Retrieve status of an order

To retrieve the status of an order, use `status` with the order key:

```ruby
response = order.status(order_key: "12345")

if response.success?
  puts response.paid?
else
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

