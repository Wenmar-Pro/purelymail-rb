# frozen_string_literal: true

RSpec.describe Purelymail do
  describe "VERSION" do
    it "is set to 0.1.0" do
      expect(Purelymail::VERSION).to eq("0.1.0")
    end
  end

  describe ".configure" do
    after do
      Purelymail.configuration.api_token = nil
    end

    it "yields the global configuration object" do
      expect { |b| Purelymail.configure(&b) }.to yield_with_args(Purelymail.configuration)
    end

    it "sets api_token on the global configuration" do
      Purelymail.configure do |config|
        config.api_token = "global-token"
      end
      expect(Purelymail.configuration.api_token).to eq("global-token")
    end
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(Purelymail.configuration).to be_a(Purelymail::Configuration)
    end

    it "memoizes the configuration" do
      expect(Purelymail.configuration).to equal(Purelymail.configuration)
    end
  end
end
