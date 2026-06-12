class VitalReading < ApplicationRecord
  belongs_to :patient

  STATUSES = %w[received processing flagged archived].freeze

  validates :metrics, presence: true
  validates :recorded_at, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :recent, -> { order(recorded_at: :desc) }
  scope :flagged, -> { where(status: "flagged") }
  scope :for_patient, ->(patient_id) { where(patient_id: patient_id).order(created_at: :asc) }

  # JSONB helpers
  def heart_rate  = metrics["heart_rate"]
  def spo2        = metrics["spo2"]
  def blood_pressure = metrics["blood_pressure"]
  def temperature = metrics["temperature"]

  def critical?
    return true if heart_rate.present? && heart_rate.to_i > 120
    return true if spo2.present? && spo2.to_i < 90
    false
  end
end
