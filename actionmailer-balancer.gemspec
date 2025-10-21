# frozen_string_literal: true

require_relative 'lib/actionmailer/balancer/version'

Gem::Specification.new do |spec|
  spec.name = 'actionmailer-balancer'
  spec.version = ActionMailer::Balancer::VERSION
  spec.authors = ['Railsware Products Studio, Inc.']
  spec.email = ['support@mailtrap.io']

  spec.summary = 'ActionMailer balancer'
  spec.description =
    'Balancer for ActionMailer. ' \
    'Distributes emails across multiple delivery methods in the given proportion.'
  spec.homepage = 'https://github.com/mailtrap/actionmailer-balancer'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/mailtrap/actionmailer-balancer'
  spec.metadata['changelog_uri'] = 'https://github.com/mailtrap/actionmailer-balancer/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_dependency 'actionmailer', '> 4.0'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:.github|bin|test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
end
