# frozen_string_literal: true

module Dada
    # Edit profile
    class EditProfile
      def self.call(id: ,data:)
        Account.where(id: id).update(data)
      end
    end
end