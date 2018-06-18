# frozen_string_literal: true

module Dada
    # Edit profile
    class EditProfile
      def self.call(account: ,data:)
        account.update(data)
      end
    end
end