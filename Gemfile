source "https://rubygems.org"

gem "rails", "~> 8.1.3"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "jsbundling-rails"
gem "cssbundling-rails"
gem "jbuilder"
gem "bcrypt", "~> 3.1.7"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem "image_processing", "~> 1.2"

# Background jobs
gem "sidekiq", "~> 7.0"

# HTTP client for EHR integration
gem "faraday", "~> 2.0"
gem "faraday-retry"

# Full-text search
gem "pg_search"

# Serializers
gem "blueprinter"

# Active Storage Azure (Rails 8 compatible)
gem "azure-blob"

# Auth
gem "jwt"

# Pagination
gem "pagy"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails", "~> 7.0"
  gem "factory_bot_rails"
  gem "faker"
  gem "webmock"
  gem "vcr"
  gem "shoulda-matchers"
end

group :development do
  gem "web-console"
  gem "bullet"
  gem "rack-mini-profiler"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "database_cleaner-active_record"
end
