# frozen_string_literal: true

require "faraday"
require "faraday/retry"

module Purelymail
  class Client
    BASE_URL = "https://purelymail.com/api/v0/"

    def initialize(api_token: nil)
      @api_token = api_token || Purelymail.configuration.api_token
    end

    def create_domain(name:)
      post("addDomain", { domainName: name })
    end

    def create_user(username:, password:)
      post("createUser", { userName: username, password: password })
    end

    def change_password(username:, new_password:)
      post("modifyUser", { userName: username, newPassword: new_password })
    end

    def create_routing_rule(domain_name:, match_user:, target_addresses:, prefix: false, catchall: false)
      post("createRoutingRule", {
        domainName: domain_name,
        matchUser: match_user,
        targetAddresses: Array(target_addresses),
        prefix: prefix,
        catchall: catchall
      })
    end

    def configured?
      !api_token.nil? && api_token.to_s.strip != ""
    end

    private

    attr_reader :api_token

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |f|
        f.options.timeout = 5
        f.options.open_timeout = 3
        f.request :json
        f.response :json
        f.request :retry, max: 3, interval: 0.5, interval_randomness: 0.5,
                          backoff_factor: 2,
                          exceptions: [Faraday::ServerError, Faraday::TimeoutError, Faraday::ConnectionFailed]
        f.adapter Faraday.default_adapter
        f.headers["Purelymail-Api-Token"] = api_token
      end
    end

    def post(endpoint, body)
      response = connection.post(endpoint, body)
      handle_response(response, endpoint)
    end

    def handle_response(response, endpoint)
      body = response.body

      if response.success? && body.is_a?(Hash) && body["type"] != "error"
        body
      else
        error_msg = if body.is_a?(Hash)
                      body["message"] || body["code"]
                    else
                      "HTTP Status #{response.status}"
                    end

        raise ApiError.new(
          "[Purelymail] #{endpoint} failed: #{error_msg}",
          status: response.status,
          response: body
        )
      end
    end
  end
end
