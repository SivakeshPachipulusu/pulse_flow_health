require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("Running in production!") if Rails.env.production?

require "rspec/rails"
require "capybara/rails"
require "capybara/rspec"
require "webmock/rspec"
require "database_cleaner/active_record"
require "shoulda/matchers"

# Allow localhost so Selenium can talk to chromedriver and Capybara's test server.
# webmock/rspec calls WebMock.reset! between tests (clears stubs only) but does NOT
# reset disable_net_connect, so this global setting persists for the whole suite.
WebMock.disable_net_connect!(allow_localhost: true)

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1400,900")

  # Use chromedriver matching the installed Chrome version (resolved via Selenium Manager)
  cached_driver = Dir.glob(File.expand_path("~/.cache/selenium/chromedriver/mac-*/*/chromedriver")).max_by { |f| File.mtime(f) }
  service = cached_driver ? Selenium::WebDriver::Chrome::Service.new(path: cached_driver) : Selenium::WebDriver::Chrome::Service.new

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, service: service)
end

Capybara.javascript_driver = :headless_chrome
Capybara.default_max_wait_time = 10
Capybara.server_port = 3099

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods

  # Use transactions for non-JS specs (fast), truncation for JS/feature specs
  # so Selenium's separate DB connection can see test data.
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |example|
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
