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
          { message: 'Password changed' }.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, { message: 'Illegal Request' }.to_json
        end
      end

      # POST api/v1/accounts/profile/edit
      routing.on 'profile' do
        routing.on 'edit' do
          routing.post do
            data = JSON.parse(routing.body.read)
            account = Account.first(username: @auth_account['username'])
            edited_account = Dada::EditProfile.call(id: account.id, data: data)
            response.status = 201
            response['Location'] = "#{@account_route}/profile/edit"
            { message: 'Profile edited'}.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => error
            puts "ERROR CREATING ACCOUNT: #{error.inspect}"
            puts error.backtrace
            routing.halt 500, { message: error.message }.to_json
          end
        end
      end

      # POST api/v1/accounts/password/edit
      routing.on 'password' do
        routing.on 'edit' do
          routing.post do
            data = JSON.parse(routing.body.read)
            account = Account.first(username: @auth_account['username'])
            # account = Account.first(username: 'victorlin12345')
            if account.password_check(account.salt,
                                      data['old_password']) == true
              account.password = (data['new_password'])
              edit_data = { :password_hash => account.password_hash,
                            :salt => account.salt }
              account.update(edit_data).to_json
              response.status = 201
              response['Location'] = "#{@account_route}/password/edit"
              { message: 'Password edited' }.to_json
            elsif data['new_password'].nil?
              { message: 'The new password cant be empty' }.to_json
            else
              { message: 'The old password is wrong' }.to_json
            end
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => error
            puts "ERROR CREATING ACCOUNT: #{error.inspect}"
            puts error.backtrace
            routing.halt 500, { message: error.message }.to_json
          end
        end
      end

      # GET api/v1/accounts/
      routing.on String do |username|
        routing.get do
          raise unless username == @auth_account['username']
          account = Account.first(username: @auth_account['username'])
          account ? account.to_json : raise('Account not found')
        rescue StandardError => error
          puts "ERROR GETTING ACCOUNT: #{error.inspect}"
          puts error.backtrace
          routing.halt 404, { message: error.message }.to_json
        end
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
