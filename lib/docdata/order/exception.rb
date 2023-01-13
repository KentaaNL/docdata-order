# frozen_string_literal: true

module Docdata
  module Order
    class Exception < StandardError
    end

    class ApiException < Docdata::Order::Exception
    end

    class InvalidResponseException < Docdata::Order::Exception
    end
  end
end
