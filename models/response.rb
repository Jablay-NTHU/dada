# frozen_string_literal: true

require 'json'
require 'sequel'

module Dada
  # Models a secret document
  class Response < Sequel::Model
    many_to_one :request

    plugin :timestamps

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
