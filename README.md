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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mailtrap/actionmailer-balancer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/mailtrap/actionmailer-balancer/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActionMailer::Balancer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mailtrap/actionmailer-balancer/blob/master/CODE_OF_CONDUCT.md).
