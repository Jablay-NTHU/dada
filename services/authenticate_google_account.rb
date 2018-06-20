# frozen_string_literal: true

require 'http'

module Dada
  # Find or create an GoogleAccount based on Google code
  class AuthenticateGoogleAccount
    def initialize(config)
      @config = config
      puts "conf: #{@config}"
    end

    def call(access_token)
      google_account = get_google_account(access_token)
      puts "goo_acc: #{google_account}"
      sso_account = find_or_create_sso_account(google_account)
      puts "goo_sso: #{sso_account}"
      [sso_account, AuthToken.create(sso_account)]
    end

    private_class_method

    def get_google_account(access_token)
      ggl_response = HTTP.get("https://www.googleapis.com/oauth2/v2/userinfo?access_token=#{access_token}")
      puts "ggl_resp: #{ggl_response}"
      raise unless ggl_response.status == 200
      account = GglAccount.new(ggl_response.parse)
      { username: account.username, email: account.email }
    end

    def find_or_create_sso_account(google_account)
      puts "Sso_ggl: #{SsoAccount.first(google_account)}"
      SsoAccount.first(email:google_account[:email]) || SsoAccount.create(google_account)
    end

    class GglAccount
      def initialize(ggl_account)
        @ggl_account = ggl_account
      end

      def username
        @ggl_account['email']
      end

      def email
        @ggl_account['email']
      end
    end
  end
end
