# frozen_string_literal: true

module Dada
  # Error for invalid credentials
  class UnauthorizedError < StandardError
    def initialize(msg = nil)
      @credentials = msg
    end

    def message
      "Invalid Credentials for: #{@credentials[:username]}"
    end
  end
  # Find account and check password
  class AuthenticateAccount
    def self.call(credentials)
      account = Account.first(username: credentials[:username])
      raise StandardError unless account.password?(credentials[:password])

      { account: account, auth_token: AuthToken.create(account) }
    rescue StandardError
      raise UnauthorizedError, credentials
    end
  end
end
