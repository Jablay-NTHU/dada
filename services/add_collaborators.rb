# frozen_string_literal: true

module Dada
  # Service object to add collaborators
  class AddCollaborators
    def self.call(project_title:, collaborators_email:)
      proj = Dada::Project.first(title: project_title)
      collaborators_email.each do |email|
        collaborator = Dada::Account.first(email: email)
        proj.add_collaborator(collaborator)
      end
    end
  end
end
