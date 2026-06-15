# frozen_string_literal: true

module Purelymail
  class ApiError < StandardError
    attr_reader :status, :response

    def initialize(message = nil, status: nil, response: nil)
      super(message)
      @status = status
      @response = response
    end
  end
end
