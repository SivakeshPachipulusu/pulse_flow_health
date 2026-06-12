FactoryBot.define do
  factory :vital_reading do
    association :patient
    sequence(:device_id) { |n| "DEV-TEST-#{n.to_s.rjust(3, "0")}" }
    device_type  { %w[Holter\ Monitor Pulse\ Oximeter Smart\ Patch].sample }
    recorded_at  { Faker::Time.backward(days: 1) }
    status       { "received" }
    anonymized   { false }
    archived     { false }
    metrics do
      {
        heart_rate:       rand(60..100),
        spo2:             rand(95..100),
        temperature:      (36.0 + rand * 1.5).round(1),
        respiratory_rate: rand(12..20),
        blood_pressure:   "#{rand(110..130)}/#{rand(70..85)}"
      }
    end

    trait :critical do
      status { "flagged" }
      metrics do
        {
          heart_rate:       rand(125..160),
          spo2:             rand(82..88),
          temperature:      (38.5 + rand * 1.0).round(1),
          respiratory_rate: rand(24..30),
          blood_pressure:   "#{rand(160..190)}/#{rand(95..110)}"
        }
      end
    end

    trait :archived do
      status     { "archived" }
      anonymized { true }
      archived   { true }
    end

    trait :flagged do
      status { "flagged" }
    end
  end
end
