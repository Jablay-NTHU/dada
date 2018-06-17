# frozen_string_literal: true

require_relative 'request'

module Dada
  # Behaviors of the currently logged in account
  class Requests
    attr_reader :all

    def initialize(request_list)
      @all = request_list.map do |req|
        Request.first(id: req.id)
               .full_details
      end
    end

    def to_json(options = {})
      JSON(@all, options)
    end
  end
end
