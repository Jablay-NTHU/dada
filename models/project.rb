# frozen_string_literal: true

require 'json'
require 'sequel'

module Dada
  # Models a project
  class Project < Sequel::Model
    many_to_one :owner, class: :'Dada::Account'

    many_to_many :collaborators,
                 class: :'Dada::Account',
                 join_table: :accounts_projects,
                 left_key: :project_id, right_key: :collaborator_id

    one_to_many :requests
    plugin :association_dependencies, requests: :destroy

    plugin :timestamps
    plugin :whitelist_security

    set_allowed_columns :title, :description, :secret_token, :public_url

    def secret_token
      SecureDB.decrypt(self.secret_token_secure)
    end

    def secret_token=(plaintext)
      self.secret_token_secure = SecureDB.encrypt(plaintext)
    end
    
    def public_url
      SecureDB.decrypt(self.public_url_secure)
    end

    def public_url=(plaintext)
      self.public_url_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'project',
            attributes: {
              id: id,
              title: title,
              description: description,
              secret_token: secret_token,
              public_url: public_url
            }
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
