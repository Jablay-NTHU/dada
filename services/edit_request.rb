# frozen_string_literal: true

module Dada
  # Edit request
  class EditRequest
    def self.call(request_id:, edit_data:)
      req = Request.first(id: request_id)
      req.update(edit_data)
    end
  end
end
  