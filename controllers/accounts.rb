# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on 'authenticate' do
        routing.post do
          credentials = JsonRequestBody.parse_symbolize(request.body.read)
          auth_account = AuthenticateAccount.call(credentials)
          auth_account.to_json
        rescue UnauthorizedError => error
          puts [error.class, error.message].join ': '
          routing.halt '403', { message: 'Invalid credentials' }.to_json
        end
        # routing.route('authenticate', 'accounts')
      end

      routing.on 'owner_ids' do
        @account_owner_ids_route = "#{@account_route}/owner_ids"
        routing.on String do |owner_id|
          routing.on 'project' do
            # POST api/v1/accounts/owner_ids/[OWNER_ID]/project
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_project = CreateProjectForOwner.call(
                owner_id: owner_id, project_data: new_data
              )
              raise('Could not save project') unless new_project.save

              response.status = 201
              response['Location'] = "#{@account_owner_ids_route}/#{new_project.id}"
              { message: 'Project saved', data: new_project }.to_json
            rescue Sequel::MassAssignmentRestriction
              routing.halt 400, { message: 'Illegal Request' }.to_json
            rescue StandardError
              routing.halt 500, { message: 'Database error' }.to_json
            end
          end
        end
      end

      routing.on String do |username|
        # GET api/v1/accounts/[USERNAME]
        routing.get do
          account = Account.first(username: username)
          account ? account.to_json : raise('Account not found')
        rescue StandardError => error
          routing.halt 404, { message: error.message }.to_json
        end
      end

      # POST api/v1/accounts
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_account = Account.new(new_data)
        raise('Could not save account') unless new_account.save

        response.status = 201
        response['Location'] = "#{@account_route}/#{new_account.id}"
        { message: 'Project saved', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => error
        puts error.inspect
        routing.halt 500, { message: error.message }.to_json
      end
    end
  end
end

