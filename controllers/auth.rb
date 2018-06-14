# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('auth') do |routing|
      routing.on 'authenticate' do
        routing.post do
          credentials = JsonRequestBody.parse_symbolize(request.body.read)
          auth_account = AuthenticateAccount.call(credentials)
          auth_account.to_json
        rescue StandardError => error
          puts "ERROR: #{error.class}: #{error.message}" 
          routing.halt '403', { message: 'Invalid credentials' }.to_json
        end
        # routing.route('authenticate', 'accounts')
      end
      routing.on 'register' do
        # POST api/v1/auth/register
        routing.post do
          reg_data = JSON.parse(routing.body.read)
          EmailVerification.new(Api.config).call(reg_data)

          response.status = 201
          { message: 'Verification email sent' }.to_json
        rescue InvalidRegistration => error
          routing.halt 400, { message: error.message }.to_json
        rescue StandardError => error
          puts "ERROR VERIFYING REGISTRATION:  #{error.inspect}"
          puts error.message
          routing.halt 500
        end
      end
    end
  end
end
