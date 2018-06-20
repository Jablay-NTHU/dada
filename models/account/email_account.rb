# frozen_string_literal: true
require_relative 'account.rb'

module Dada
  # Models an email registered account
  class EmailAccount < Account
    def password=(new_password)
      self.salt = SecureDB.new_salt
      self.password_hash = SecureDB.hash_password(salt, new_password)
    end
    def password?(try_password)
      try_hashed = SecureDB.hash_password(salt, try_password)
      try_hashed == password_hash
    end
  end
end
