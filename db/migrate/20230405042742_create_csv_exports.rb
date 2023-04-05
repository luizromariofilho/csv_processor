# frozen_string_literal: true

class CreateCsvExports < ActiveRecord::Migration[7.0]
  def change
    create_table :csv_exports do |t|
      t.references :user, null: false, foreign_key: true
      t.string :s3_path
      t.datetime :finished_at
      t.datetime :started_at
      t.datetime :failed_at
      t.json :filters
      t.integer :row_count
      t.integer :state, default: 0
      t.string :email

      t.timestamps
    end
  end
end
