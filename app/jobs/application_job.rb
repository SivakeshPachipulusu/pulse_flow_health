class ApplicationJob < ActiveJob::Base
  queue_adapter :sidekiq

  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3
  discard_on ActiveJob::DeserializationError
end
