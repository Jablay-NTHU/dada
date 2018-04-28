# frozen_string_literal: true

require 'json'
require 'roda'

require_relative 'config/environments'
require_relative 'models/init'

module Dada
  # Web controller for Dada API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'Dada API up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          @api_root = 'api/v1'

          routing.on 'projects' do
            @projects_route = "#{@api_root}/projects"

            # GET api/v1/projects
            routing.get do
              { message: 'Get all projects info' }.to_json
            end
          end

          routing.on 'project' do
            routing.on String do |id_proj|

              routing.on 'requests' do
                # GET api/v1/project/[id_proj]/requests
                routing.get do
                  { message: 'Get all requests info given a project' }.to_json
                end
              end

              routing.on 'request' do
                # GET api/v1/project/[id_proj]/request/[id_req]
                routing.on String do |id_req|
                  routing.get do
                    { message: "Get a request info #{id_req} given a project #{id_proj}" }.to_json
                  end
                end

                # POST api/v1/project/[ID]/request
                routing.post do
                  { message: 'Post a new request API Call' }.to_json
                end
              end

              # GET api/v1/project/[ID]
              routing.get do
                { message: "Get a project #{id_proj} info" }.to_json
              end              
            end

            # POST api/v1/project
            routing.post do
              { message: 'Post a new project' }.to_json
            end
          end
        end
      end
    end
  end
end
