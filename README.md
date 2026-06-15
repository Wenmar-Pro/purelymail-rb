# Purelymail

A standalone Ruby client for the [Purelymail API](https://purelymail.com/).

## Installation

Add this to your `Gemfile`:

```ruby
gem "purelymail"
```

Then run `bundle install`.

Or install it yourself:

```bash
gem install purelymail
```

## Usage

### Per-Instance Configuration

```ruby
client = Purelymail::Client.new(api_token: "pm-live-xxxxxxxx")
client.create_domain(name: "example.com")
```

### Global Configuration

```ruby
Purelymail.configure do |config|
  config.api_token = "pm-live-xxxxxxxx"
end

client = Purelymail::Client.new
client.create_user(name: "alice", domain: "example.com", password: "s3cret")
```

You can mix both: pass an `api_token` to `Client.new` to override the global config for that instance.

### API Methods

```ruby
client = Purelymail::Client.new(api_token: "pm-live-xxxxxxxx")

client.create_domain(name: "example.com")

client.create_user(name: "alice", domain: "example.com", password: "s3cret")

client.change_password(name: "alice", domain: "example.com", password: "newpass")

client.create_routing_rule(
  domain_name: "example.com",
  match_user: "alice",
  target_addresses: ["alice@destination.com"],
  prefix: false,
  catchall: false
)

client.configured?
# => true
```

### Error Handling

All API errors raise `Purelymail::ApiError`:

```ruby
begin
  client.create_domain(name: "invalid@domain")
rescue Purelymail::ApiError => e
  puts e.message      # => "[Purelymail] addDomain failed: ..."
  puts e.status       # => 400
  puts e.response     # => {"type" => "error", "message" => "..."}
end
```

## Rails Integration

Add the gem to your `Gemfile`:

```ruby
gem "purelymail"
```

Configure via Rails credentials:

```bash
bin/rails credentials:edit
```

Add:

```yaml
purelymail:
  api_token: pm-live-xxxxxxxx
```

The gem automatically picks up `Rails.application.credentials.dig(:purelymail, :api_token)` as a fallback, so you can use the client without any explicit configuration:

```ruby
# config/initializers/purelymail.rb
Purelymail.configure do |config|
  # config.api_token is optional here —
  # it will fall back to Rails.application.credentials.purelymail.api_token
end
```

Then anywhere in your app:

```ruby
Purelymail::Client.new.create_domain(name: "example.com")
```

If you need to override the token at the call site, pass it directly:

```ruby
Purelymail::Client.new(api_token: "pm-live-yyyyyyyy")
```

## Development

After checking out the repo, run:

```bash
bundle install
bundle exec rspec
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
