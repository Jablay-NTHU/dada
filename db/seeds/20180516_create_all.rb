# frozen_string_literal: true

Sequel.seed(:development) do
    def run
      # puts 'Seeding accounts, projects, documents'
      puts 'Seeding accounts, projects'
      create_accounts
      create_owned_projects
      add_collaborators
    #   create_documents
    #   add_collaborators
    end
end
  
require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNERS_INFO = YAML.load_file("#{DIR}/owners_seed.yml")
PROJS_INFO = YAML.load_file("#{DIR}/projects_seed.yml")
COLLS_INFO = YAML.load_file("#{DIR}/collaborators_seed.yml")
# DOCUMENT_INFO = YAML.load_file("#{DIR}/documents_seed.yml")

  
def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Dada::Account.create(account_info)
  end
end
  
def create_owned_projects
  OWNERS_INFO.each do |owner|
    account = Dada::Account.first(username: owner['username'])
    owner['proj_title'].each do |proj_title|
      proj_data = PROJS_INFO.find { |proj| proj['title'] == proj_title }
      Dada::CreateProjectForOwner.call(
        owner_id: account.id, project_data: proj_data
      )
    end
  end
end

def add_collaborators
    collaborators_info = COLLS_INFO
    collaborators_info.each do |collaborator|
        title = collaborator['project_title']
        emails = collaborator['collaborators_email']
        Dada::AddCollaborators.call(
            project_title: title, collaborators_email: emails
        )
    end
  end
  
#   def create_documents
#     doc_info_each = DOCUMENT_INFO.each
#     projects_cycle = Credence::Project.all.cycle
#     loop do
#       doc_info = doc_info_each.next
#       project = projects_cycle.next
#       Credence::CreateDocumentForProject.call(
#         project_id: project.id, document_data: doc_info
#       )
#     end
#   end
  
