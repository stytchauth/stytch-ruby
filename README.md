# Stytch

Welcome to the offical Stytch ruby gem! This gem provides easy access to Stytch's API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stytch'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install stytch

## Usage

To make a request, first create a Stytch Client.
Set `env` to either `:test` or `:api` depending on which environment you want to use.
```
client = Stytch::Client.new(
    env: :test,
    client_id: "***",
    secret: "***"
)
```

Then make desired API call.
```
client.get_user(user_id: user_id)
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Stytch project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/stytch/blob/master/CODE_OF_CONDUCT.md).
