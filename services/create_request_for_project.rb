# frozen_string_literal: true

module Dada
  # Create new request for a project
  class CreateRequestForProject
    def self.call(project_id:, request_data:)
      Project.first(id: project_id)
             .add_request(request_data)
    end
  end
end