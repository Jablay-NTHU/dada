# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:tokens) do
      primary_key :id
      foreign_key :owner_id, :accounts

      String :name, null: false
      String :value_secure, null: false
      String :description
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
