# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, projects, requests, responses'
    create_accounts
    create_owned_projects
    add_collaborators
    create_requests
    create_responses
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_projects.yml")
PROJ_INFO = YAML.load_file("#{DIR}/projects_seed.yml")
COLL_INFO = YAML.load_file("#{DIR}/projects_collaborators_seed.yml")
REQ_INFO = YAML.load_file("#{DIR}/requests_seed.yml")
RES_INFO = YAML.load_file("#{DIR}/responses_seed.yml")

def create_accounts
  ALL_ACCOUNTS_INFO.each do |account_info|
    CreateAccount.call(account_info)
  end
end

def create_owned_projects
    OWNER_INFO.each do |owner|
        account = Dada::Account.first(username: owner['username'])
        owner['proj_name'].each do |proj_name|
          proj_data = PROJ_INFO.find { |proj| proj['name'] == proj_name }
          Dada::CreateProjectForOwner.call(
            owner_id: account.id, project_data: proj_data
          )
        end
    end
end

def create_requests
  req_info_each = REQ_INFO.each
  projects_cycle = Dada::Project.all.cycle
  loop do
    req_info = req_info_each.next
    project = projects_cycle.next
    Dada::CreateRequestForProject.call(
      project_id: project.id, req_name: req.id
    )
  end
end

def create_responses
    res_info_each = RES_INFO.each
    projects_cycle = Dada::Project.all.cycle
    loop do
      res_info = res_info_each.next
      project = projects_cycle.next
      Dada::CreateResponseForRequest.call(
        project_id: project.id, request_id: req.id, 
        response_id: res.id
      )
    end
  end

  def add_collaborators
    contrib_info = CONTRIB_INFO
    contrib_info.each do |contrib|
      proj = Dada::Project.first(name: coll['proj_name'])
      contrib['collaborator_email'].each do |email|
        collaborator = Dada::Account.first(email: email)
        proj.add_collaborator(collaborator)
      end
    end
  end