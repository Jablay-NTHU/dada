# frozen_string_literal: true

require 'json'
require 'sequel'

module Dada
  # Models a secret response
  class Response < Sequel::Model
    many_to_one :request

    plugin :timestamps
    plugin :whitelist_security

    set_allowed_columns :request_id, :status_code, :header, :body

    def header
      SecureDB.decrypt(self.header_secure)
    end

    def header=(plaintext)
      self.header_secure = SecureDB.encrypt(plaintext)
    end

    def body
      SecureDB.decrypt(self.body_secure)
    end

    def body=(plaintext)
      self.body_secure = SecureDB.encrypt(plaintext)
    end

    def to_h
      {
        type: 'response',
        id: id,
        status_code: status_code,
        header: header,
        body: body,
        created_at: created_at,
        request: request
      }
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
