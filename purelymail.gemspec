# frozen_string_literal: true

require_relative "lib/purelymail/version"

Gem::Specification.new do |spec|
  spec.name = "purelymail"
  spec.version = Purelymail::VERSION
  spec.authors = ["Ben D'Angelo"]
  spec.email = ["ben@bendangelo.me"]
  spec.summary = "Ruby client for the Purelymail API"
  spec.description = "A standalone Ruby gem for interacting with the Purelymail API. Manage domains, users, routing rules, and more."
  spec.homepage = "https://github.com/bendangelo/purelymail-rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*"]
  spec.files += ["README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-retry", "~> 2.0"
end
