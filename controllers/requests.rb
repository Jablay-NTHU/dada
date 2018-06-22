# frozen_string_literal: true

require 'roda'
module Dada
  # Web controller for Dada API
  class Api < Roda
    route('requests') do |routing|
      @req_route = "#{@api_root}/requests"

      # GET api/v1/requests/[req_id]
      routing.on String do |req_id|
        # POST /requests/[req_id]/delete
        routing.on 'request_call' do
          routing.get do
            account = Account.first(username: @auth_account['username'])
            request = Request.first(id: req_id)
            policy = RequestPolicy.new(account, request)
            raise unless policy.can_add_response?
            # Calling the api
            parameters = YAML.safe_load(request.parameters)

            # Should be able to call api
            test_request = HTTP.headers(parameters)
                               .get(request.call_url)

            res_data = {}
            res_data['status_code'] = test_request.code
            res_data['header'] = test_request.headers.to_hash.to_yaml
            res_data['body'] = test_request.body

            new_response = Dada::CreateResponseForRequest.call(
              request_id: req_id, response_data: res_data
            )
            response.status = 201
            { message: 'Response added', data: request }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.halt 404, { message: 'Request not found' }.to_json
          end
        end

        # POST /requests/[req_id]/delete
        routing.on 'delete' do
          routing.post do
            account = Account.first(username: @auth_account['username'])
            request = Request.first(id: req_id)
            policy = RequestPolicy.new(account, request)
            raise unless policy.can_delete?
            Request.where(id: req_id).destroy
            response.status = 201
            { message: 'Request deleted', data: request }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.ha
            lt 404, { message: 'Request not found' }.to_json
          end
        end

        # POST /requests/[req_id]/edit
        routing.on 'edit' do
          routing.post do
            account = Account.first(username: @auth_account['username'])
            request = Request.first(id: req_id)
            policy = RequestPolicy.new(account, request)
            raise unless policy.can_edit?

            req_data = JSON.parse(routing.body.read)
            Request.where(id: req_id).update(req_data)
            req = Request.first(id: req_id)
            # puts req
            # if !once --> time = 1 / 7 / 30
            next_interval = ''
            if req.interval != 'once'
              seq = 1 if req.interval == 'daily'
              seq = 7 if req.interval == 'weekly'
              seq = 30 if req.interval == 'monthly'
              next_interval = req.date_start + seq
              next_interval = '' if next_interval > req.date_end
            end
            Dada::Request.where(id: req_id).update(next_request: next_interval)
            # puts y
            # puts y.class
            # puts y.interval
            # puts y.date_start
            # puts next_interval

            response.status = 201
            { message: 'Request edited', data: req }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.halt 404, { message: 'Request not found' }.to_json
          end
        end

        # POST /requests/[req_id]/response
        routing.on 'response' do
          routing.post do
            account = Account.first(username: @auth_account['username'])
            request = Request.first(id: req_id)
            policy = RequestPolicy.new(account, request)
            raise unless policy.can_add_response?

            res_data = JSON.parse(routing.body.read)
            new_response = Dada::CreateResponseForRequest.call(
              request_id: req_id, response_data: res_data
            )
            response.status = 201
            response['Location'] = "#{@req_route}/#{req_id}/response"
            { message: 'Response saved', data: new_response }.to_json
          rescue StandardError # => error
            # puts "ERROR: #{error.inspect}"
            # puts error.backtrace
            routing.halt 404, { message: 'Request not found' }.to_json
          end
        end

        # GET /requests/[req_id]
        routing.get do
          account = Account.first(username: @auth_account['username'])
          request = Request.where(id: req_id).first
          policy = RequestPolicy.new(account, request)
          raise unless policy.can_view?
          request.full_details
                 .merge(policies: policy.summary)
                 .to_json
        rescue StandardError # => error
          # puts "ERROR: #{error.inspect}"
          # puts error.backtrace
          routing.halt 404, { message: 'Request not found' }.to_json
        end
      end
    end
  end
end
