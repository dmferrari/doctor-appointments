# frozen_string_literal: true

class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :appointments do |t|
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.datetime :appointment_date, null: false
      t.string :start_time, null: false
      t.string :end_time, null: false

      t.timestamps
    end

    add_index :appointments, :appointment_date
    add_index :appointments, %i[doctor_id patient_id appointment_date], unique: true
  end
end
