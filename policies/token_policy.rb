# frozen_string_literal: true

module Dada
  # Policy to determine if account can view a token
  class TokenPolicy
    def initialize(account, token)
      @account = account
      @token = token
    end

    def can_view?
      account_owns_token?
    end

    def can_edit?
      account_owns_token?
    end

    def can_delete?
      account_owns_token?
    end

    def summary
      {
        can_view:   can_view?,
        can_edit:   can_edit?,
        can_delete: can_delete?
      }
    end

    private

    def account_owns_token?
      @token.owner == @account
    end

    # def account_collaborates_on_project?
    #   @response.request.project.collaborators.include?(@account)
    # end
  end
end
