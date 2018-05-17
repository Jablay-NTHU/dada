# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('request') do |routing|
      routing.on String do |req_id|
        # GET api/v1/request/[req_id]/responses
        routing.on 'responses' do
          routing.get do
            req = Request.first(id: req_id)
            req ? req.to_json : raise('Request not found')
          rescue StandardError => error
            routing.halt 404, { message: error.message }.to_json
          end
        end

        routing.on 'response' do
          routing.on String do |res_id|
            # GET api/v1/request/[req_id]/response/[res_id]
            routing.get do
              res = Response.where(request_id: req_id, id: res_id).first
              res ? res.to_json : raise('Response not found')
            rescue StandardError => error
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # POST api/v1/request/[req_id]/response
          routing.post do
            new_data = JSON.parse(routing.body.read)

            new_res = CreateResponseForRequest.call(
              request_id: req_id, response_data: new_data
            )

            response.status = 201
            response['Location'] = "#{@res_route}/#{new_res.id}"
            { message: 'Response saved', data: new_res }.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError
            routing.halt 500, { message: 'Database error' }.to_json
          end
        end
      end
    end
  end
end

