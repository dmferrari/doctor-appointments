# frozen_string_literal: true

class CreateDoctorProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :doctor_profiles do |t|
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.integer :session_length, null: false
      t.string :specialty

      t.timestamps
    end

    add_index :doctor_profiles, :specialty
  end
end
