# frozen_string_literal: true

module Dada
# Policy to determine if account can view a project
  class RequestPolicy
    def initialize(account, request)
      @account = account
      @request = request
    end

    def can_view?
      account_owns_project? || account_collaborates_on_project?
    end

    def can_edit?
      account_owns_project? || account_collaborates_on_project?
    end

    def can_delete?
      account_owns_project? || account_collaborates_on_project?
    end

    def can_view_response?
      account_owns_project? || account_collaborates_on_project?
    end

    def can_add_response?
      account_owns_project? || account_collaborates_on_project?
    end

    def can_remove_response?
      account_owns_project? || account_collaborates_on_project?
    end

    def can_export_response?
      account_owns_project? || account_collaborates_on_project?
    end

    def summary
      {
        can_view:   can_view?,
        can_edit:   can_edit?,
        can_delete: can_delete?,
        can_view_response: can_view_response?,
        can_add_response: can_add_response?,
        can_remove_response: can_remove_response?,
        can_export_response: can_export_response?
      }
    end

    private

    def account_owns_project?
      @request.project.owner == @account
    end

    def account_collaborates_on_project?
      @request.project.collaborators.include?(@account)
    end
  end
end
