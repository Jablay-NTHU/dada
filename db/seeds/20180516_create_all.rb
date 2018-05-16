# frozen_string_literal: true

Sequel.seed(:development) do
    def run
      # puts 'Seeding accounts, projects, documents'
      puts 'Seeding accounts'
      create_accounts
      create_owned_projects
    #   create_documents
    #   add_collaborators
    end
end
  
require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_seed.yml")
PROJ_INFO = YAML.load_file("#{DIR}/projects_seed.yml")
# DOCUMENT_INFO = YAML.load_file("#{DIR}/documents_seed.yml")
# CONTRIB_INFO = YAML.load_file("#{DIR}/projects_collaborators.yml")
  
def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Dada::Account.create(account_info)
  end
end
  
def create_owned_projects
  OWNER_INFO.each do |owner|
    account = Dada::Account.first(username: owner['username'])
    owner['proj_title'].each do |proj_title|
      proj_data = PROJ_INFO.find { |proj| proj['title'] == proj_title }
      Dada::CreateProjectForOwner.call(
        owner_id: account.id, project_data: proj_data
      )
    end
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
  
#   def add_collaborators
#     contrib_info = CONTRIB_INFO
#     contrib_info.each do |contrib|
#       proj = Credence::Project.first(name: contrib['proj_name'])
#       contrib['collaborator_email'].each do |email|
#         collaborator = Credence::Account.first(email: email)
#         proj.add_collaborator(collaborator)
#       end
#     end
#   end