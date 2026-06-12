FactoryBot.define do
  factory :patient do
    sequence(:mrn) { |n| "MRN-TEST-#{n.to_s.rjust(4, "0")}" }
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    gender     { %w[male female other].sample }
    date_of_birth { Faker::Date.birthday(min_age: 20, max_age: 90) }
    ward       { %w[Cardiology ICU Neurology Geriatrics].sample }
    status     { "active" }
    diagnosis_notes { Faker::Lorem.sentence(word_count: 8) }
    email      { Faker::Internet.email }
    phone      { Faker::PhoneNumber.phone_number }

    trait :icu do
      ward { "ICU" }
    end

    trait :discharged do
      status { "discharged" }
    end

    trait :with_vitals do
      after(:create) do |patient|
        create_list(:vital_reading, 5, patient: patient)
      end
    end

    trait :with_critical_vitals do
      after(:create) do |patient|
        create(:vital_reading, :critical, patient: patient)
      end
    end
  end
end
