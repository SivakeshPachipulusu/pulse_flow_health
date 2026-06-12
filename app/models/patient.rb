class Patient < ApplicationRecord
  include PgSearch::Model

  has_many :vital_readings, dependent: :destroy

  pg_search_scope :search_by_name_and_notes,
    against: {
      first_name: "A",
      last_name:  "A",
      mrn:        "B",
      diagnosis_notes: "C"
    },
    using: {
      tsearch: { prefix: true, dictionary: "english" }
    }

  STATUSES = %w[active discharged deceased].freeze

  validates :first_name, :last_name, presence: true
  validates :mrn, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where(status: "active") }
  scope :by_ward, ->(ward) { where("lower(ward) = lower(?)", ward) }

  def full_name
    "#{first_name} #{last_name}"
  end
end
