# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      # POST api/v1/accounts/password/edit
      routing.on 'password' do
        routing.on 'edit' do
          routing.post do
            data = JSON.parse(routing.body.read)
            account = Account.first(username: @auth_account['username'])
            # account = Account.first(username: 'victorlin12345')
            account.password=(data['new_password'])
            edit_data = { :password_hash => account.password_hash, :salt => account.salt}
            result = account.update(edit_data).to_json
            response.status = 201
            response['Location'] = "#{@account_route}/password/edit"
            { message: 'Password edited'}.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => error
            puts "ERROR CREATING ACCOUNT: #{error.inspect}"
            puts error.backtrace
            routing.halt 500, { message: error.message }.to_json
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
        new_account = EmailAccount.new(new_data)
        raise('Could not save account') unless new_account.save

        response.status = 201
        response['Location'] = "#{@account_route}/#{new_account.id}"
        { message: 'Account created', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => error
        puts "ERROR CREATING ACCOUNT: #{error.inspect}"
        puts error.backtrace
        routing.halt 500, { message: error.message }.to_json
      end
    end
  end
end
