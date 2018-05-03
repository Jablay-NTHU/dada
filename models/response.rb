# frozen_string_literal: true

require 'json'
require 'sequel'

module Dada
  # Models a secret document
  class Response < Sequel::Model
    many_to_one :request

    plugin :timestamps
    plugin :whitelist_security

    set_allowed_columns :request_id, :status_code, :header, :body

    def header=(plaintext)
      self.header_secure = SecureDB.encrypt(plaintext)
    end

    def header
      SecureDB.decrypt(self.header_secure)
    end

    def body=(plaintext)
      self.body_secure = SecureDB.encrypt(plaintext)
    end

    def body
      SecureDB.decrypt(self.body_secure)
    end

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'response',
            attributes: {
              id: id,
              status_code: status_code,
              header_secure: header_secure,
              body_secure: body_secure
            }
          },
          included: {
            request: request
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
