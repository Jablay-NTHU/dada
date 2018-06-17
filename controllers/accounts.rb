# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on 'change_password' do
        # POST api/v1/accounts/change_password
        routing.post do
          account = SignedRequest.new(Api.config).parse(request.body.read)
          # account = JSON.parse(routing.body.read)
          Dada::ChangePassword.call(
            email: account['email'], edit_data: account
          )
          response.status = 201
          { message: 'Password changed'}.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue StandardError => error
          puts "ERROR CREATING ACCOUNT: #{error.inspect}"
          puts error.backtrace
          routing.halt 500, { message: error.message }.to_json
        end
      end

      # GET api/v1/accounts/[USERNAME]
      routing.get do
        account = Account.first(username: @auth_account['username'])
        account ? account.to_json : raise('Account not found')
      rescue StandardError => error
        puts "ERROR GETTING ACCOUNT: #{error.inspect}"
        puts error.backtrace
      routing.halt 404, { message: error.message }.to_json
      end

      # POST api/v1/accounts
      routing.post do
        new_data = SignedRequest.new(Api.config).parse(request.body.read)
        # new_data = JSON.parse(routing.body.read)
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
