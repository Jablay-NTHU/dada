# frozen_string_literal: true

module Dada
  # Create new request for a project
  class CreateResponseForRequest
    def self.call(request_id:, response_data:)
      Request.first(id: request_id)
             .add_response(response_data)
    end
  end
end