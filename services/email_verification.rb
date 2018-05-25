# frozen_string_literal: true

module Dada
  class InvalidRegistration < StandardError; end

  class EmailVerification
    # Send email verification
    def send_email_verification(registration)
      HTTP.auth("Bearer #{@config.SENDGRID_KEY}").post(
        SENDGRID_URL,
        json: {
          personalizations: [{
            to: [{ 'email' => registration['email'] }]
          }],
          from: { 'email' => 'noreply@dada.com' },
          subject: 'Dada Registration Verification',
          content: [{
            type: 'text/html',
            value: email_body(registration)
          }]
        }
      )
    rescue StandardError
      raise(InvalidRegistration,
            'Could not send verification email; please check email ...')
    end

    def call(registration)
      raise(InvalidRegistration, 'Username already exists') unless
        username_available?(registration)

      send_email_verification(registration)
    end
  end
end
