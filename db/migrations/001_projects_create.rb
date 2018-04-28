# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:projects) do
      primary_key :id

      String :title, null: false
      String :descriptions
      String :secret_content_secure
      String :public_url_secure, unique: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
