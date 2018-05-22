# frozen_string_literal: true

require 'json'
require 'sequel'

module Dada
  # Models a token
  class Token < Sequel::Model
    many_to_one :owner_token, class: :'Dada::Account'

    plugin :timestamps
    plugin :whitelist_security

    set_allowed_columns :name, :value, :description, :owner_id

    def value
      SecureDB.decrypt(value_secure)
    end

    def value=(plaintext)
      self.value_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'token',
            attributes: {
              id: id,
              name: name,
              value: value,
              description: description
            }
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
