# frozen_string_literal: true

RSpec.describe Purelymail::Configuration do
  subject(:config) { described_class.new }

  describe "#api_token" do
    it "defaults to nil" do
      expect(config.api_token).to be_nil
    end

    it "returns the value set via writer" do
      config.api_token = "my-token"
      expect(config.api_token).to eq("my-token")
    end

    it "allows setting to nil" do
      config.api_token = "my-token"
      config.api_token = nil
      expect(config.api_token).to be_nil
    end

    context "when Rails is defined with credentials" do
      before do
        stub_const("Rails", rails_double)
      end

      let(:rails_double) do
        double("Rails", application: double("App", credentials: credentials_double))
      end
      let(:credentials_double) do
        double("Credentials", dig: "rails-credential-token")
      end

      it "falls back to Rails.application.credentials" do
        expect(config.api_token).to eq("rails-credential-token")
      end
    end

    context "when Rails is defined but has no credentials" do
      before do
        stub_const("Rails", double("Rails"))
      end

      it "returns nil" do
        expect(config.api_token).to be_nil
      end
    end
  end
end
