# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.1'
gem 'rails', '~> 7.1'

gem 'active_model_serializers'
gem 'acts_as_paranoid'
gem 'bootsnap'
gem 'bundler'
gem 'cancancan'
gem 'devise'
gem 'devise-jwt'
gem 'pg'
gem 'puma'
gem 'redis'
gem 'rolify'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'sidekiq-scheduler'

group :development, :test do
  gem 'byebug'
  gem 'dotenv-rails', '~> 3.1'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rubocop', require: false
  gem 'rubocop-rails'
end

group :development do
  gem 'bullet'
  gem 'letter_opener'
  gem 'rack-mini-profiler'
  gem 'rails-perftest'
  gem 'reek'
  gem 'ruby-lsp'
  gem 'ruby-prof'
  gem 'spring'
end

group :test do
  gem 'rspec-rails'
  gem 'rspec-sidekiq'
  gem 'shoulda-matchers'
end
