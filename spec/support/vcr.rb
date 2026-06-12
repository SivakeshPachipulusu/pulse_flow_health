require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.filter_sensitive_data("<EHR_TOKEN>") { ENV["EHR_API_TOKEN"] }
  c.default_cassette_options = { record: :new_episodes }
end
