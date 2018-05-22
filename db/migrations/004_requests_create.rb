# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:requests) do
      primary_key :id
      foreign_key :project_id, table: :projects

      String :title, null: false
      String :description
      String :api_url, null: false
      String :interval, null: false, default: 'once'
      String :parameters_secure, null: false, default: ''
      Date :date_start
      Date :date_end
      String :json_path
      String :xml_path

      DateTime :created_at
      DateTime :updated_at

      # unique [:project_id, :relative_path, :filename]
    end
  end
end
