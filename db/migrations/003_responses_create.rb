# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:responses) do
      primary_key :id
      foreign_key :request_id, table: :requests

      Integer :status_code, null: false
      String :header_secure, null: false
      String :body_secure, null: false

      DateTime :created_at
      DateTime :updated_at

    end
  end
end
