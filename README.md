# Stytch Ruby Gem

The Stytch Ruby gem makes it easy to use the Stytch user infrastructure API in Ruby applications.

It pairs well with the Stytch [Web SDK](https://www.npmjs.com/package/@stytch/stytch-js) or your own custom authentication flow.

## Install

Add this line to your application's Gemfile:

```ruby
gem 'stytch'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install stytch

## Usage

You can find your API credentials in the [Stytch Dashboard](https://stytch.com/dashboard/api-keys).

This client library supports all of Stytch's live products:
  - [x] [Email Magic Links](https://stytch.com/docs/api/send-by-email)
  - [x] [Embeddable Magic Links](https://stytch.com/docs/api/create-magic-link-overview)
  - [x] [OAuth logins](https://stytch.com/docs/api/oauth-overview)
  - [x] [SMS passcodes](https://stytch.com/docs/api/send-otp-by-sms)
  - [x] [WhatsApp passcodes](https://stytch.com/docs/api/whatsapp-send)
  - [x] [Email passcodes](https://stytch.com/docs/api/send-otp-by-email)
  - [x] [Session Management](https://stytch.com/docs/api/sessions-overview)
  - [x] [WebAuthn (Beta)](https://stytch.com/docs/api/webauthn-overview)
  - [x] [Time-based one-time passcodes (TOTPs) (Beta)](https://stytch.com/docs/api/totps-overview)
  - [x] [Crypto wallets (Beta)](https://stytch.com/docs/api/crypto-wallet-overview)

### Example usage
Create an API client:
```ruby
client = Stytch::Client.new(
    env: :test, # available environments are :test and :live
    project_id: "***",
    secret: "***"
)
```

Send a magic link by email:
```ruby
client.magic_links.email.login_or_create(
    email: "sandbox@stytch.com"
)
```

Authenticate the token from the magic link:
```ruby
client.magic_links.authenticate(
    token: "SeiGwdj5lKkrEVgcEY3QNJXt6srxS3IK2Nwkar6mXD4="
)
```

## Handling Errors

When possible the response will contain an `error_type` and an `error_message` that can be used to distinguish errors.

Learn more about errors in the [docs](https://stytch.com/docs/api/errors).

## Documentation

See example requests and responses for all the endpoints in the [Stytch API Reference](https://stytch.com/docs/api).

Follow one of the [integration guides](https://stytch.com/docs/guides) or start with one of our [example apps](https://stytch.com/docs/example-apps).

## Support

If you've found a bug, [open an issue](https://github.com/stytchauth/stytch-ruby/issues/new)!

If you have questions or want help troubleshooting, join us in [Slack](https://join.slack.com/t/stytch/shared_invite/zt-nil4wo92-jApJ9Cl32cJbEd9esKkvyg) or email support@stytch.com.

If you've found a security vulnerability, please follow our [responsible disclosure instructions](https://stytch.com/docs/security).

## Development

See [DEVELOPMENT.md](DEVELOPMENT.md)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Stytch project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
