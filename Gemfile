# frozen_string_literal: true

source 'http://rubygems.org'

gemspec

gem 'codeclimate-test-reporter', group: :test, require: nil
gem 'guard', require: false
gem 'guard-rspec', require: false
gem 'pg', '~> 0.21'
gem 'pry-rails', require: false
gem 'solidus', '< 3'

group :tools do
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :development, :test do
  gem 'capybara', '~> 2.2'
  gem 'database_cleaner'
  gem 'factory_bot'
  gem 'ffaker'
  gem 'pry'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 3'
  gem 'rspec-xsd'
  gem 'sass-rails'
  gem 'simplecov'
  gem 'sqlite3'
  gem 'timecop'
end
