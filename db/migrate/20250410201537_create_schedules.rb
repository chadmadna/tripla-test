class CreateSchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :schedules do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :clock_in
      t.datetime :clock_out
      t.string :description
      t.integer :lock_version, default: 0

      t.timestamps
      t.index :clock_in
      t.index [:id, :clock_in]
    end
  end
end
