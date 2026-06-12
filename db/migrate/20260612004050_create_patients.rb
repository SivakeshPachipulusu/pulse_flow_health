class CreatePatients < ActiveRecord::Migration[8.1]
  def change
    create_table :patients, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :mrn, null: false
      t.date   :date_of_birth
      t.string :gender
      t.string :email
      t.string :phone
      t.text   :diagnosis_notes
      t.string :ward
      t.string :status, default: "active", null: false
      t.jsonb  :metadata, default: {}
      t.timestamps
    end

    add_index :patients, :mrn, unique: true
    add_index :patients, :status
    add_index :patients, :last_name
  end
end
