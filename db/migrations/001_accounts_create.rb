# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts) do
      primary_key :id

      String :type
      String :username, null: false, unique: true
      String :email, null: false, unique: true
      String :password_hash
      String :salt
      String :profile_img
      DateTime :created_at
      DateTime :updated_at

      unique [:type, :username]
    end
  end
end
