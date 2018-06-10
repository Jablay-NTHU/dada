# frozen_string_literal: true

require 'json'
require 'sequel'

module Dada
  # Models a token
  class Token < Sequel::Model
    many_to_one :owner, class: :'Dada::Account'

    plugin :timestamps
    plugin :whitelist_security

    set_allowed_columns :name, :value, :description, :owner_id

    def value
      SecureDB.decrypt(value_secure)
    end

    def value=(plaintext)
      self.value_secure = SecureDB.encrypt(plaintext)
    end

    def to_h
      {
        type: 'token',
        id: id,
        name: name,
        value: value,
        description: description
      }
    end

    def to_json(options = {})
      JSON(to_h, options)
    end

    def full_details
      to_h.merge(
        owner: owner
      )
    end
  end
end
