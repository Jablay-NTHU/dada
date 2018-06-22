# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('authenticate', 'auth') do |routing|
      routing.on do
        # POST /api/v1/auth/authenticate/sso_account
        routing.post 'sso_account' do
          auth_request = JsonRequestBody.parse_symbolize(request.body.read)

          sso_account, auth_token =
            AuthenticateSsoAccount.new(Api.config)
                                  .call(auth_request[:access_token])
          { account: sso_account, auth_token: auth_token }.to_json
        rescue StandardError # => error
          # puts "FAILED to validate Github account: #{error.inspect}"
          # puts error.backtrace
          routing.halt 400
        end

        # POST /api/v1/auth/authenticate/email_account
        routing.post 'email_account' do
          credentials = JsonRequestBody.parse_symbolize(request.body.read)
          auth_account = AuthenticateEmailAccount.call(credentials)
          auth_account.to_json
        rescue StandardError # => error
          # puts "ERROR: #{error.class}: #{error.message}"
          routing.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end
    end
  end
end
