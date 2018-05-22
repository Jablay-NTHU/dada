# frozen_string_literal: true

require 'json'
require 'sequel'

module Dada
  # Models a secret request
  class Request < Sequel::Model
    many_to_one :project

    one_to_many :responses

    plugin :association_dependencies, responses: :destroy
    plugin :timestamps
    plugin :whitelist_security

    set_allowed_columns :project_id, :title, :description, :api_url,
                        :interval, :parameters, :date_start, :date_end,
                        :json_path, :xml_path

    def parameters
      SecureDB.decrypt(parameters_secure)
    end

    def parameters=(plaintext)
      self.parameters_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'request',
            attributes: {
              id: id,
              title: title,
              description: description,
              api_url: api_url,
              interval: interval,
              parameters: parameters,
              date_start: date_start,
              date_end: date_end,
              json_path: json_path,
              xml_path: xml_path
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
