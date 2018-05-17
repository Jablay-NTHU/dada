# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('projects') do |routing|
      @proj_route = "#{@api_root}/projects"
      # GET api/v1/projects
      routing.get do
        output = { data: Project.all }
        JSON.pretty_generate(output)
      rescue StandardError
        routing.halt 404, { message: 'Could not find projects' }.to_json
      end
    end
  end
end
