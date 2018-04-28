# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:requests) do
      primary_key :id
      foreign_key :project_id, table: :projects

      String :api_url, null: false
      String :scheduled, null: false, default: 'once'
      String :parameters, null: false, default: ''
      Date :date_start
      Date :date_end

      DateTime :created_at
      DateTime :updated_at

      # unique [:project_id, :relative_path, :filename]
    end
  end
end
