# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('authenticate', 'accounts') do |routing|
      # POST /api/v1/accounts/authenticate
      routing.post do
        credentials = JsonRequestBody.parse_symbolize(request.body.read)
        auth_account = AuthenticateAccount.call(credentials)
        auth_account.to_json
      rescue UnauthorizedError => error
        puts [error.class, error.message].join ': '
        routing.halt '403', { message: 'Invalid credentials' }.to_json
      end
    end
  end
end
