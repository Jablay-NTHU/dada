# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('projects') do |routing|
      @proj_route = "#{@api_root}/projects"

      # GET api/v1/projects/[proj_id]
      routing.on String do |proj_id|

        # POST api/v1/projects/[proj_id]/delete
        routing.on 'delete' do
          routing.post do
            account = Account.first(username: @auth_account['username'])
            project = Project.first(id: proj_id)
            policy  = ProjectPolicy.new(account, project)
            raise unless policy.can_delete?
            Project.where(id: proj_id).delete
            response.status = 201
            { message: 'Project deleted' }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.halt 404, { message: 'Project not found' }.to_json
          end
        end

        # POST api/v1/projects/[proj_id]/leave
        routing.on 'leave' do
          routing.post do
            account = Account.first(username: @auth_account['username'])
            project = Project.first(id: proj_id)
            policy  = ProjectPolicy.new(account, project)
            raise unless policy.can_leave?
            project.remove_collaborator(account)
            response.status = 201
            { message: 'Project leaved' }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.halt 404, { message: 'Project not found' }.to_json
          end
        end

        # POST api/v1/projects/[proj_id]/edit
        routing.on 'edit' do
          routing.post do
            proj_data = JSON.parse(routing.body.read)
            account = Account.first(username: @auth_account['username'])
            project = Project.first(id: proj_id)
            policy  = ProjectPolicy.new(account, project)
            raise unless policy.can_edit?
            project.update(proj_data)
            response.status = 201
            { message: 'Project edited' }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.halt 404, { message: 'Project not found' }.to_json
          end
        end

        # POST api/v1/projects/[proj_id]/request
        routing.on 'request' do
          routing.post do
            data = JSON.parse(routing.body.read)
            req_data = {}
            req_data['title'] = data['title']
            req_data['description'] = data['description']
            req_data['api_url'] = data['api_url']
            req_data['parameters'] = data['parameters']
            req_data['interval'] = data['interval']
            res_data = {}
            res_data['status_code'] = data['status_code']
            res_data['header'] = data['header']
            res_data['body'] = data['body']

            new_request = Dada::CreateRequestForProject.call(
              project_id: proj_id, request_data: req_data
            )
            Dada::CreateResponseForRequest.call(
              request_id: new_request.id, response_data: res_data
            )
            # account = Account.first(username: @auth_account['username'])
            # project = Project.first(id: proj_id)
            # policy  = ProjectPolicy.new(account, project)
            # raise unless policy.can_edit?
            response.status = 201
            { message: 'Request saved' }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.halt 404, { message: 'Request not found' }.to_json
          end
        end

        routing.get do
          # account = Account.first(username: 'agoeng.bhimasta')
          account = Account.first(username: @auth_account['username'])
          project = Project.first(id: proj_id)
          policy  = ProjectPolicy.new(account, project)
          raise unless policy.can_view?
          project.full_details
                 .merge(policies: policy.summary)
                 .to_json
        rescue StandardError => error
          puts "ERROR: #{error.inspect}"
          puts error.backtrace
          routing.halt 404, { message: 'Project not found' }.to_json
        end
      end

      # GET api/v1/projects
      routing.get do
        # account = Account.first(username: 'agoeng.bhimasta')
        account = Account.first(username: @auth_account['username'])
        projects_scope = ProjectPolicy::AccountScope.new(account)
        viewable_projects = projects_scope.viewable
        proj = Projects.new(viewable_projects, account)
        proj.to_json
        # JSON.pretty_generate(proj)
      rescue StandardError => error
        puts "ERROR: #{error.inspect}"
        puts error.backtrace
        routing.halt 403, { message: 'Could not find projects' }.to_json
      end

      # POST api/v1/projects
      routing.post do
        proj_data = JSON.parse(routing.body.read)
        account = Account.first(username: @auth_account['username'])
        new_proj = Dada::CreateProjectForOwner.call(
          owner_id: account.id, project_data: proj_data
        )
        response.status = 201
        { message: 'Project saved', data: new_proj }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => error
        puts "ERROR: #{error.inspect}"
        puts error.backtrace
        routing.halt 500, { message: error.message }.to_json
      end
    end
  end
end
