# frozen_string_literal: true

require 'sequel'
require 'json'

module Dada
  # Models a registered account
  class Account < Sequel::Model
    plugin :single_table_inheritance, :type,
            model_map: { 'email' => 'Dada::EmailAccount',
                         'sso'   => 'Dada::SsoAccount' }
    one_to_many :owned_projects, class: :'Dada::Project', key: :owner_id
    plugin :association_dependencies, owned_projects: :destroy

    one_to_many :owned_tokens, class: :'Dada::Token', key: :owner_id
    plugin :association_dependencies, owned_tokens: :destroy

    many_to_many :collaborations,
                 class: :'Dada::Project',
                 join_table: :accounts_projects,
                 left_key: :collaborator_id, right_key: :project_id

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password, :password_hash, :salt, :profile_url
    # set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    # only set the object, not yet store in db
    def password=(new_password)
      self.salt = SecureDB.new_salt
      self.password_hash = SecureDB.hash_password(salt, new_password)
    end

    def password_check(salt, try_password)
      try_hashed = SecureDB.hash_password(salt, try_password)
      return try_hashed == password_hash
    end

    def projects
      owned_projects + collaborations
    end

    def to_json(options = {})
      JSON(
        {
          type: 'type',
          id: id,
          username: username,
          email: email
        }, options
      )
    end
  end
end
