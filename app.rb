# frozen_string_literal: true

require 'json'
require 'roda'
require 'base64'

require_relative 'models/project'

module Dada
  # Web controller for Dada API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Project.setup
    end

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'Dada API up at /api/v1' }.to_json
      end
      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'project' do
            # GET api/v1/project/[ID]
            routing.get String do |id|
              Project.find(id).to_json                          
            rescue StandardError
              routing.halt 404, { message: 'Project not found' }.to_json
            end
            # POST api/v1/project
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_exp = Project.new(new_data)
              if new_exp.save
                response.status = 201
                { message: 'Project saved', id: new_exp.id }.to_json
              else
                routing.halt 400, { message: "Couldn't save project" }.to_json
              end
            end
          end
          routing.on 'projects' do
            # GET api/v1/projects
            routing.get do
              output = { project_ids: Project.all }
              JSON.pretty_generate(output)
            end
          end
        end
      end
    end
  end
end
