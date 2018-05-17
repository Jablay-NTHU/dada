# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, projects, requests, responses'
    create_accounts
    create_owned_projects
    create_requests
    create_responses
    add_collaborators
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNERS_INFO = YAML.load_file("#{DIR}/owners_seed.yml")
PROJS_INFO = YAML.load_file("#{DIR}/projects_seed.yml")
COLLS_INFO = YAML.load_file("#{DIR}/collaborators_seed.yml")
REQUEST_INFO = YAML.load_file("#{DIR}/requests_seed.yml")
RESPONSE_INFO = YAML.load_file("#{DIR}/responses_seed.yml")

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

def create_requests
  req_info_each = REQUEST_INFO.each
  projects_cycle = Dada::Project.all.cycle
  loop do
    req_info = req_info_each.next
    project = projects_cycle.next
    Dada::CreateRequestForProject.call(
      project_id: project.id, request_data: req_info
    )
  end
end

def create_responses
  res_info_each = RESPONSE_INFO.each
  request_cycle = Dada::Request.all.cycle
  loop do
    res_info = res_info_each.next
    request = request_cycle.next
    Dada::CreateResponseForRequest.call(
      request_id: request.id, response_data: res_info
    )
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
