class CreateVitalReadings < ActiveRecord::Migration[8.1]
  def change
    create_table :vital_readings, id: :uuid, default: "gen_random_uuid()" do |t|
      t.references :patient, type: :uuid, null: false, foreign_key: true
      t.string  :device_id
      t.string  :device_type
      t.jsonb   :metrics, null: false, default: {}
      t.string  :status, default: "received"
      t.boolean :anonymized, default: false, null: false
      t.boolean :archived, default: false, null: false
      t.datetime :recorded_at, null: false
      t.timestamps
    end

    # Composite index for chronological charts per patient
    add_index :vital_readings, [:patient_id, :created_at]

    # GIN index for fast JSONB vitals queries (e.g. WHERE metrics @> '{"heart_rate": 120}')
    add_index :vital_readings, :metrics, using: :gin

    add_index :vital_readings, :status
    add_index :vital_readings, :recorded_at
  end
end
