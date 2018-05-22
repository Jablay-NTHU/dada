# frozen_string_literal: true

module Dada
  # Create new token for a user
  class CreateTokenForUser
    def self.call(owner_id:, token_data:)
      Account.first(id: owner_id)
             .add_owned_token(token_data)
    end
  end
end
