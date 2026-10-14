# ActionMailer Balancer

This gem allows you to send your ActionMailer mail through one of several delivery methods, selected by weight. 

Applications:

- gradually migrate to a new mail provider (first 1% of mail, then 5%, and so on)
- ...or to a new configuration (SMTP to Email API)
- spread load between multiple providers

Works with any valid ActionMailer delivery methods, either built-in or added from a library like [mailtrap](https://github.com/mailtrap/mailtrap-ruby#actionmailer).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'actionmailer-balancer'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install actionmailer-balancer

## Usage

Add the configuration to Rails env initializer

```ruby
Your::Application.configure do
  config.action_mailer.delivery_method = :balancer
  config.action_mailer.balancer_settings = {
    delivery_methods: [
      {
        method: :smtp,
        settings: {
          user_name: username,
          password: password,
          address: host,
          domain: domain,
          port: port,
          authentication: auth_method
        },
        weight: 90
      },
      {
        method: :sendmail,
        settings: {
          location: '/path/to/your/sendmail'
        },
        weight: 10
      }
    ]
  }
end
```

Now, just use ActionMailer as usual, and mail will be auto-balanced. 

### Mixing SMTP and API delivery methods

Delivery methods don't have to use SMTP. Any delivery method registered with ActionMailer works, including ones that send through a provider's HTTP API. For example, to keep 90% of mail on your current SMTP provider and move 10% to the [Mailtrap Email API](https://github.com/mailtrap/mailtrap-ruby#actionmailer):

```ruby
# Gemfile
gem 'actionmailer-balancer'
gem 'mailtrap' # registers the :mailtrap delivery method
```

```ruby
Your::Application.configure do
  config.action_mailer.delivery_method = :balancer
  config.action_mailer.balancer_settings = {
    delivery_methods: [
      {
        method: :smtp,
        settings: {
          address: 'smtp.example.com',
          port: 587,
          user_name: ENV.fetch('SMTP_USERNAME'),
          password: ENV.fetch('SMTP_PASSWORD'),
          authentication: :plain
        },
        weight: 90
      },
      {
        method: :mailtrap,
        settings: {
          api_key: ENV.fetch('MAILTRAP_API_KEY')
        },
        weight: 10
      }
    ]
  }
end
```

`settings` are passed to each delivery method as they are, so use the keys that method expects (for `:mailtrap`, see the [mailtrap gem](https://github.com/mailtrap/mailtrap-ruby#actionmailer)). To move more mail to the new provider, change the weights. A weight of `0` turns a delivery method off without removing its configuration.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mailtrap/actionmailer-balancer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/mailtrap/actionmailer-balancer/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActionMailer::Balancer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mailtrap/actionmailer-balancer/blob/master/CODE_OF_CONDUCT.md).
