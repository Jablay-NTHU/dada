# frozen_string_literal: true

module Dada
  # Service object to add collaborators
  class AddCollaboratorsByProjId
    def self.call(proj_id:, collaborators_email:)
      proj = Project.first(id: proj_id)
      collaborators_email.each do |email|
        collaborator = Dada::Account.first(email: email)
        proj.add_collaborator(collaborator)
      end
    end
  end
end
