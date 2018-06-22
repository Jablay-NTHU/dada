# frozen_string_literal: true

require 'http'

module Dada
  # Error for invalid credentials
  class NotRegistered < StandardError; end

  # Find account and check password
  class EmailRecovery
    SENDGRID_URL = 'https://api.sendgrid.com/v3/mail/send'

    def initialize(config)
      @config = config
    end

    def email_available?(email_data)
      # puts "5#{email_data}"
      EmailAccount.first(email: email_data[:email])
    end

    def email_recovery_body(email_data)
      verification_url = email_data[:verification_url]
      # puts "#{verification_url}"

      <<~END_EMAIL
        <p>Dear #{email_data[:email]}, </p>
        <p>We received a request to reset your Dada account password. </br>
        To reset your Dada password, please <a href=\"#{verification_url}\">click here</a></p>
        <p>Best regards,</br>
        Dada</p>
        </br>
        <hr>
        <p>Please do not reply to this email. </br>
        This email address is used only for sending email
        so you will not receive a response. 
      END_EMAIL
    end

    # rubocop:disable Metrics/MethodLength
    def send_email_verification(email_data)
      HTTP.auth(
        "Bearer #{@config.SENDGRID_KEY}"
      ).post(
        SENDGRID_URL,
        json: {
          personalizations: [{
            to: [{ 'email' => email_data[:email] }]
          }],
          from: { 'email' => 'noreply@dada.com' },
          subject: 'Dada Password Reset',
          content: [
            { type: 'text/html',
              value: email_recovery_body(email_data) }
          ]
        }
      )
    rescue StandardError => error
      # puts error.message
      raise(NotRegistered,
            'Could not send verification email; please check email address')
    end
    # rubocop:enable Metrics/MethodLength

    def call(registration)
      # puts "#{registration}""
      raise(NotRegistered, 'Cannot Find Email Account') unless
      email_available?(registration)

      send_email_verification(registration)
    end
  end
end
