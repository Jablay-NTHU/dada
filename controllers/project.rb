# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('project') do |routing|
      routing.on String do |proj_id|
        routing.on 'requests' do
          # GET api/v1/project/[proj_id]/requests
          routing.get do
            output = Project.first(id: proj_id).requests
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find requests' }
          end
        end

        routing.on 'request' do
          @req_route = "#{@api_root}/project/#{proj_id}/request"
          # GET api/v1/project/[proj_id]/request/[req_id]
          routing.on String do |req_id|
            routing.get do
              req = Request.where(project_id: proj_id, id: req_id).first
              req ? req.to_json : raise('Request not found')
            rescue StandardError => error
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # POST api/v1/project/[proj_id]/request
          routing.post do
            new_data = JSON.parse(routing.body.read)

            new_req = CreateRequestForProject.call(
              project_id: proj_id, request_data: new_data
            )

            response.status = 201
            response['Location'] = "#{@req_route}/#{new_req.id}"
            { message: 'Request saved', data: new_req }.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError
            routing.halt 500, { message: 'Database error' }.to_json
          end
        end

        # GET api/v1/project/[proj_id]
        routing.get do
          proj = Project.first(id: proj_id)
          proj ? proj.to_json : raise('Project not found')
        rescue StandardError => error
          routing.halt 404, { message: error.message }.to_json
        end
      end

      # POST api/v1/project
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_proj = Project.new(new_data)
        raise('Could not save project') unless new_proj.save

        response.status = 201
        response['Location'] = "#{@projects_route}/#{new_proj.id}"
        { message: 'Project saved', data: new_proj }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => error
        routing.halt 400, { message: error.message }.to_json
      end
    end
  end
end

