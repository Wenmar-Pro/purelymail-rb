# frozen_string_literal: true

RSpec.describe Purelymail::ApiError do
  subject(:error) do
    described_class.new("Something went wrong", status: 400, response: { "type" => "error", "message" => "Bad request" })
  end

  describe "#message" do
    it "returns the error message" do
      expect(error.message).to eq("Something went wrong")
    end
  end

  describe "#status" do
    it "returns the HTTP status code" do
      expect(error.status).to eq(400)
    end
  end

  describe "#response" do
    it "returns the response payload" do
      expect(error.response).to eq({ "type" => "error", "message" => "Bad request" })
    end
  end

  describe "inheritance" do
    it "is a StandardError" do
      expect(error).to be_a(StandardError)
    end
  end
end
