# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('responses') do |routing|
      @res_route = "#{@api_root}/responses"

      # GET api/v1/responses/[res_id]
      routing.on String do |res_id|
        # POST /responses/[res_id]/add_response
        routing.on 'add_response' do
          routing.get do
            account = Account.first(username: @auth_account['username'])
            res = Response.first(id: res_id)
            policy = ResponsePolicy.new(account, res)
            raise unless policy.can_delete?
            # puts res.to_json
            Response.where(id: res_id).destroy
            response.status = 201
            { message: 'Response deleted', data: res }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.halt 404, { message: 'Request not found' }.to_json
          end
        end

        routing.on 'delete' do
          routing.post do
            account = Account.first(username: @auth_account['username'])
            res = Response.first(id: res_id)
            policy = ResponsePolicy.new(account, res)
            raise unless policy.can_delete?
            # puts res.to_json
            Response.where(id: res_id).destroy
            response.status = 201
            { message: 'Response deleted', data: res }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.halt 404, { message: 'Request not found' }.to_json
          end
        end

        routing.get do
          account = Account.first(username: @auth_account['username'])
          response = Response.where(id: res_id).first
          policy = ResponsePolicy.new(account, response)
          raise unless policy.can_view?
          response ? response.to_json : raise
        rescue StandardError # => error
          # puts "ERROR: #{error.inspect}"
          # puts error.backtrace
          routing.halt 404, { message: 'Response not found' }.to_json
        end
      end
    end
  end
end
