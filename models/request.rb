# frozen_string_literal: true

require 'json'
require 'sequel'

module Dada
  # Models a secret document
  class Request < Sequel::Model
    many_to_one :project

    one_to_many :responses
    plugin :association_dependencies, responses: :destroy

    plugin :timestamps

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'request',
            attributes: {
              id: id,
              api_url: api_url,
              scheduled: scheduled,
              parameters: parameters,
              date_start: date_start,
              date_end: date_end
            }
          },
          included: {
            project: project
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
