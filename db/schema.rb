# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_12_004051) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "patients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.text "diagnosis_notes"
    t.string "email"
    t.string "first_name", null: false
    t.string "gender"
    t.string "last_name", null: false
    t.jsonb "metadata", default: {}
    t.string "mrn", null: false
    t.string "phone"
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.string "ward"
    t.index ["last_name"], name: "index_patients_on_last_name"
    t.index ["mrn"], name: "index_patients_on_mrn", unique: true
    t.index ["status"], name: "index_patients_on_status"
  end

  create_table "vital_readings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "anonymized", default: false, null: false
    t.boolean "archived", default: false, null: false
    t.datetime "created_at", null: false
    t.string "device_id"
    t.string "device_type"
    t.jsonb "metrics", default: {}, null: false
    t.uuid "patient_id", null: false
    t.datetime "recorded_at", null: false
    t.string "status", default: "received"
    t.datetime "updated_at", null: false
    t.index ["metrics"], name: "index_vital_readings_on_metrics", using: :gin
    t.index ["patient_id", "created_at"], name: "index_vital_readings_on_patient_id_and_created_at"
    t.index ["patient_id"], name: "index_vital_readings_on_patient_id"
    t.index ["recorded_at"], name: "index_vital_readings_on_recorded_at"
    t.index ["status"], name: "index_vital_readings_on_status"
  end

  add_foreign_key "vital_readings", "patients"
end
