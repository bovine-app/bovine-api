# frozen_string_literal: true

class CreateSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :user_agent
      t.inet :created_from, null: false
      t.inet :last_accessed_from
      t.datetime :last_accessed_at, precision: 6
      t.datetime :expires_at, precision: 6, null: false

      t.timestamps
    end
  end
end
