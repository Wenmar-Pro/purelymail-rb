# frozen_string_literal: true

RSpec.describe Purelymail::Client do
  let(:api_token) { "pm-live-test-token" }

  subject(:client) { described_class.new(api_token: api_token) }

  before do
    Purelymail.configuration.api_token = nil
  end

  describe "#initialize" do
    it "stores the provided api_token" do
      expect(client.instance_variable_get(:@api_token)).to eq(api_token)
    end

    context "when no token is given" do
      it "falls back to the global configuration" do
        Purelymail.configure { |c| c.api_token = "global-token" }
        c = described_class.new
        expect(c.instance_variable_get(:@api_token)).to eq("global-token")
      end

      it "sets api_token to nil when no global config is set" do
        c = described_class.new
        expect(c.instance_variable_get(:@api_token)).to be_nil
      end
    end

    context "when an explicit token is given alongside a global config" do
      it "prefers the explicit token" do
        Purelymail.configure { |c| c.api_token = "global-token" }
        c = described_class.new(api_token: "explicit-token")
        expect(c.instance_variable_get(:@api_token)).to eq("explicit-token")
      end
    end
  end

  describe "#configured?" do
    it "returns true when api_token is present" do
      expect(client).to be_configured
    end

    it "returns false when api_token is nil" do
      c = described_class.new(api_token: nil)
      expect(c).not_to be_configured
    end

    it "returns false when api_token is an empty string" do
      c = described_class.new(api_token: "")
      expect(c).not_to be_configured
    end

    it "returns false when api_token is whitespace only" do
      c = described_class.new(api_token: "   ")
      expect(c).not_to be_configured
    end
  end

  shared_examples "an API endpoint" do |endpoint, method_name, params, expected_body|
    before do
      stub_request(:post, "https://purelymail.com/api/v0/#{endpoint}")
        .with(headers: { "Purelymail-Api-Token" => api_token })
        .to_return(
          status: 200,
          body:    { type: "success" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "sends a POST to #{endpoint}" do
      client.public_send(method_name, **params)
      expect(
        a_request(:post, "https://purelymail.com/api/v0/#{endpoint}")
          .with(headers: { "Purelymail-Api-Token" => api_token })
      ).to have_been_made.once
    end

    it "encodes the body as JSON" do
      client.public_send(method_name, **params)
      expect(
        a_request(:post, "https://purelymail.com/api/v0/#{endpoint}")
      ).to have_been_made.once
    end

    it "returns the parsed response body" do
      result = client.public_send(method_name, **params)
      expect(result).to eq({ "type" => "success" })
    end

    it "raises ApiError on a non-success response" do
      stub_request(:post, "https://purelymail.com/api/v0/#{endpoint}")
        .to_return(
          status: 400,
          body:   { "type" => "error", "message" => "Something went wrong" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      expect { client.public_send(method_name, **params) }
        .to raise_error(Purelymail::ApiError) do |e|
          expect(e.status).to eq(400)
          expect(e.response).to eq({ "type" => "error", "message" => "Something went wrong" })
        end
    end
  end

  describe "#create_domain" do
    it_behaves_like "an API endpoint", "addDomain", :create_domain,
                    { name: "example.com" },
                    { domainName: "example.com" }
  end

  describe "#create_user" do
    it_behaves_like "an API endpoint", "createUser", :create_user,
                    { name: "alice", domain: "example.com", password: "s3cret" },
                    { userName: "alice", domainName: "example.com", password: "s3cret" }
  end

  describe "#change_password" do
    it_behaves_like "an API endpoint", "changePassword", :change_password,
                    { name: "alice", domain: "example.com", password: "newpass" },
                    { userName: "alice", domainName: "example.com", password: "newpass" }
  end

  describe "#create_routing_rule" do
    it_behaves_like "an API endpoint", "createRoutingRule", :create_routing_rule,
                    { domain_name: "example.com", match_user: "alice", target_addresses: "alice@other.com" },
                    { domainName: "example.com", matchUser: "alice", targetAddresses: ["alice@other.com"], prefix: false, catchall: false }

    context "when target_addresses is an array" do
      it_behaves_like "an API endpoint", "createRoutingRule", :create_routing_rule,
                      { domain_name: "example.com", match_user: "alice", target_addresses: ["a@b.com", "c@d.com"] },
                      { domainName: "example.com", matchUser: "alice", targetAddresses: ["a@b.com", "c@d.com"], prefix: false, catchall: false }
    end

    context "when prefix is true" do
      it_behaves_like "an API endpoint", "createRoutingRule", :create_routing_rule,
                      { domain_name: "example.com", match_user: "alice", target_addresses: "alice@other.com", prefix: true },
                      { domainName: "example.com", matchUser: "alice", targetAddresses: ["alice@other.com"], prefix: true, catchall: false }
    end
  end

  describe "faraday middleware configuration" do
    it "has retry middleware configured" do
      handler_classes = client.send(:connection).builder.handlers.map(&:klass)
      expect(handler_classes).to include(Faraday::Retry::Middleware)
    end

    it "has json request and response middleware configured" do
      handler_classes = client.send(:connection).builder.handlers.map(&:klass)
      expect(handler_classes).to include(Faraday::Request::Json)
      expect(handler_classes).to include(Faraday::Response::Json)
    end

    it "sets the Purelymail-Api-Token header" do
      expect(client.send(:connection).headers["Purelymail-Api-Token"]).to eq(api_token)
    end
  end
end
