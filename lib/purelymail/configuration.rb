# frozen_string_literal: true

module Purelymail
  class Configuration
    attr_writer :api_token

    def api_token
      @api_token || rails_credentials_token
    end

    private

    def rails_credentials_token
      if defined?(Rails) && Rails.respond_to?(:application) && Rails.application.respond_to?(:credentials)
        Rails.application.credentials.dig(:purelymail, :api_token)
      end
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
