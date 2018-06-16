# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('requests') do |routing|
      @req_route = "#{@api_root}/requests"
      @account = Account.first(username: @auth_account['username'])

      # GET api/v1/requests/[req_id]
      routing.get(String) do |req_id|
        project = Project.first(id: proj_id)
        @policy = ProjectPolicy.new(@account, project)

        # POST /requests/[req_id]/edit
        routing.on 'edit' do
          routing.post do
            edit_data = JSON.parse(routing.body.read)
            raise unless @policy.can_edit_requests?
            Dada::EditRequest.call(
              request_id: req_id, edit_data: edit_data
            )
            response.status = 201
            { message: 'Request edited' }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.halt 404, { message: 'Request not found' }.to_json
          end
        end

        # POST /requests/[req_id]/delete
        routing.on 'delete' do
          routing.post do
            raise unless @policy.can_remove_requests?
            Request.where(id: req_id).delete
            response.status = 201
            { message: 'Request deleted' }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.halt 404, { message: 'Request not found' }.to_json
          end
        end

        # GET api/v1/requests/[req_id]
        routing.get do
          account = Account.first(username: @auth_account['username'])
          request = Request.where(id: req_id).first
          policy = RequestPolicy.new(account, request)
          raise unless policy.can_view?
          request.full_details
                 .merge(policies: policy.summary)
                 .to_json
        rescue StandardError => error
          puts "ERROR: #{error.inspect}"
          puts error.backtrace
          routing.halt 404, { message: 'Request not found' }.to_json
        end
      end
    end
  end
end
