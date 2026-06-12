module Vitals
  class AnonymizeAndArchiveJob < ApplicationJob
    queue_as :vitals
    sidekiq_options retry: 3

    retry_on ActiveRecord::ConnectionNotEstablished, wait: 5.seconds, attempts: 3
    discard_on ActiveRecord::RecordNotFound

    def perform(vital_reading_id)
      reading = VitalReading.find(vital_reading_id)

      reading.metrics.delete("device_serial")
      reading.metrics.delete("raw_payload")
      reading.update!(anonymized: true, archived: true, status: "archived")
    end
  end
end
