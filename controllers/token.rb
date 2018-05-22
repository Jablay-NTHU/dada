# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('token') do |routing|
      @token_route = "#{@api_root}/token"
      routing.on String do |tok_id|
        # GET api/v1/token/[tok_id]
        routing.get do
          tok = Token.first(id: tok_id)
          tok ? tok.to_json : raise('Token not found')
        rescue StandardError => error
          routing.halt 404, { message: error.message }.to_json
        end
      end

      # GET v1/api/token
      routing.get do
        # { message: 'Get all token' }.to_json
        output = { data: Token.all }
        JSON.pretty_generate(output)
      rescue StandardError
        routing.halt 404, { message: 'Could not find tokens' }.to_json
      end

      # POST api/v1/token
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_token = Token.new(new_data)
        raise('Could not save token') unless new_token.save

        response.status = 201
        response['Location'] = "#{@token_route}/#{new_token.id}"
        { message: 'Token saved', data: new_token }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => error
        routing.halt 400, { message: error.message }.to_json
      end
    end
  end
end
