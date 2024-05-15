# frozen_string_literal: true

class CreateWorkingHours < ActiveRecord::Migration[7.1]
  def change
    create_table :working_hours do |t|
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.date :working_date, null: false
      t.string :start_time, null: false
      t.string :end_time, null: false

      t.timestamps
    end

    add_index :working_hours, %i[doctor_id working_date], unique: true
  end
end
