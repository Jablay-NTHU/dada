# frozen_string_literal: true

module Dada
    # Policy to determine if an account make the requests
    class RequestPolicy
      def initialize(account, project)
        @account = account
        @project = project
      end
  
      def can_view?
        account_is_owner? || account_is_collaborator?
      end
  
      # duplication is ok!
      def can_edit?
        account_is_owner? || account_is_collaborator?
      end
  
      def can_add?
        account_is_owner? || account_is_collaborator?
      end
  
      def can_remove?
        account_is_owner? || account_is_collaborator?
      end
  
      def summary
        {
          can_view_requests: can_view?,
          can_add_requests: can_add?,
          can_edit_requests: can_edit?,
          can_remove_requests: can_remove?,
        }
      end
  
      private
  
      def account_is_owner?
        @project.owner == @account
      end
  
      def account_is_collaborator?
        @project.collaborators.include?(@account)
      end
    end
  end