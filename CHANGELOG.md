## [1.2.2] - 2026-07-02

## What's Changed
* Bump rack from 3.1.18 to 3.1.20 by @dependabot[bot] in https://github.com/mailtrap/actionmailer-balancer/pull/50
* Bump actionview from 7.1.5.1 to 7.2.3.1 by @dependabot[bot] in https://github.com/mailtrap/actionmailer-balancer/pull/51
* Bump rack from 3.1.20 to 3.1.21 by @dependabot[bot] in https://github.com/mailtrap/actionmailer-balancer/pull/53
* Bump rack-session from 2.1.1 to 2.1.2 by @dependabot[bot] in https://github.com/mailtrap/actionmailer-balancer/pull/54
* Bump net-imap from 0.4.20 to 0.4.24 by @dependabot[bot] in https://github.com/mailtrap/actionmailer-balancer/pull/55
* Bump net-imap from 0.4.24 to 0.5.15 by @dependabot[bot] in https://github.com/mailtrap/actionmailer-balancer/pull/56
* Bump concurrent-ruby from 1.3.6 to 1.3.7 by @dependabot[bot] in https://github.com/mailtrap/actionmailer-balancer/pull/57
* Add draft-release workflow placeholder by @IgorDobryn in https://github.com/mailtrap/actionmailer-balancer/pull/58
* Implement draft-release workflow by @IgorDobryn in https://github.com/mailtrap/actionmailer-balancer/pull/59


**Full Changelog**: https://github.com/mailtrap/actionmailer-balancer/compare/v1.2.1...v1.2.2

## [1.2.0] - 2025-03-06

- Drop Ruby 3.0 support
- Update dependencies

## [1.1.2] - 2024-12-13

- Allow Rails 8 

  *Alex Ghiculescu*

## [1.1.1] - 2024-12-09

- Fix crash when no settings are provided for a delivery method
  
  ```ruby
  config.action_mailer.balancer_settings = {
    delivery_methods: [
      {
        method: :mailtrap,
        weight: 1
      }
    ]
  }
  ``` 

  *Alex Ghiculescu*

## [1.1.0] - 2024-08-19

- Drop Ruby 2.7 support
- Update dependencies

## [1.0.0] - 2022-10-07

- Initial release
