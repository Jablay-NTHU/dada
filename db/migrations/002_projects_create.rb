# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:projects) do
      primary_key :id
      foreign_key :owner_id, :accounts

      String :title, null: false
      String :description, null: true
      String :secret_token_secure, null: false
      String :public_url_secure, null: true, unique: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
