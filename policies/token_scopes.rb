# frozen_string_literal: true

module Dada
  # Policy to determine if account can view a token
  class TokenPolicy
    # Scope of project policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_tokens(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        @full_scope if @current_account == @target_account
      end

      private

      def all_tokens(account)
        account.owned_tokens
      end
    end
  end
end
