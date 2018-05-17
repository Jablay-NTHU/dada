# frozen_string_literal: true

module Dada
  # Service object to create a new project for an owner
  class CreateProjectForOwner
    def self.call(owner_id:, project_data:)
      # owner_id = Account.first(username: owner_name).id
      # Project.new(project_data)
      Account.first(id: owner_id)
             .add_owned_project(project_data)
    end
  end
end
