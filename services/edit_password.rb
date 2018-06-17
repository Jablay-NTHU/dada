# frozen_string_literal: true

module Dada
  # Edit password
  class EditPassword
    def self.call(new_password:)
      Account.password=(new_password)
    end
  end
end