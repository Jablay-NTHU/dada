# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('projects') do |routing|
      @proj_route = "#{@api_root}/projects"

      routing.on String do |proj_id|
        # POST api/v1/projects/[proj_id]/delete
        routing.on 'delete' do
          routing.post do
            account = Account.first(username: @auth_account['username'])
            project = Project.first(id: proj_id)
            policy = ProjectPolicy.new(account, project)
            raise unless policy.can_delete?

            Project.where(id: proj_id).destroy

            response.status = 201
            { message: 'Project deleted' }.to_json
          rescue StandardError # => error
            # puts "ERROR: #{error.inspect}"
            # puts error.backtrace
            routing.halt 404, { message: 'Project not found' }.to_json
          end
        end

        # POST api/v1/projects/[proj_id]/leave
        routing.on 'leave' do
          routing.post do
            account = Account.first(username: @auth_account['username'])
            project = Project.first(id: proj_id)
            policy = ProjectPolicy.new(account, project)
            raise unless policy.can_leave?

            project.remove_collaborator(account)

            response.status = 201
            { message: 'Project leaved' }.to_json
          rescue StandardError # => error
            # puts "ERROR: #{error.inspect}"
            # puts error.backtrace
            routing.halt 404, { message: 'Project not found' }.to_json
          end
        end

        # POST api/v1/projects/[proj_id]/edit
        routing.on 'edit' do
          routing.post do
            account = Account.first(username: @auth_account['username'])
            project = Project.first(id: proj_id)
            policy = ProjectPolicy.new(account, project)
            raise unless policy.can_edit?

            proj_data = JSON.parse(routing.body.read)
            project.update(proj_data)

            response.status = 201
            { message: 'Project edited' }.to_json
          rescue StandardError # => error
            # puts "ERROR: #{error.inspect}"
            # puts error.backtrace
            routing.halt 404, { message: 'Project not found' }.to_json
          end
        end

        # POST api/v1/projects/[proj_id]/collaborator
        routing.on 'collaborator' do
          routing.post do
            account = Account.first(username: @auth_account['username'])
            project = Project.first(id: proj_id)
            policy = ProjectPolicy.new(account, project)
            raise unless policy.can_add_collaborators?

            collaborators = JSON.parse(routing.body.read)
            Dada::AddCollaboratorsByProjId.call(
              proj_id: proj_id, collaborators_email: collaborators
            )

            response.status = 201
            { message: 'Collaborator added' }.to_json
          rescue StandardError # => error
            # puts "ERROR: #{error.inspect}"
            # puts error.backtrace
            routing.halt 404, { message: 'Project not found' }.to_json
          end
        end

        # POST api/v1/projects/[proj_id]/remove_collaborator
        routing.on 'remove_collaborator' do
          routing.post do
            account = Account.first(username: @auth_account['username'])
            project = Project.first(id: proj_id)
            policy = ProjectPolicy.new(account, project)
            raise unless policy.can_remove_collaborators?

            collaborators = JSON.parse(routing.body.read)
            account = Account.first(username: collaborators['username'])
            project.remove_collaborator(account)
            response.status = 201
            { message: 'Collaborator added' }.to_json
          rescue StandardError # => error
            # puts "ERROR: #{error.inspect}"
            # puts error.backtrace
            routing.halt 404, { message: 'Project not found' }.to_json
          end
        end

        # POST api/v1/projects/[proj_id]/request
        routing.on 'request' do
          routing.post do
            account = Account.first(username: @auth_account['username'])
            project = Project.first(id: proj_id)
            policy = ProjectPolicy.new(account, project)
            raise unless policy.can_add_requests?

            req_data = JSON.parse(routing.body.read)
            req = Dada::CreateRequestForProject.call(
              project_id: proj_id, request_data: req_data
            )
            # if !once --> time = 1 / 7 / 30
            if req.interval != 'once'
              seq = 1 if req.interval == 'daily'
              seq = 7 if req.interval == 'weekly'
              seq = 30 if req.interval == 'monthly'
              # puts seq
              next_interval = req.date_start + seq
              if (next_interval) <= req.date_end
                Dada::Request.where(id: req.id)
                             .update(next_request: next_interval)
              end
            end
            # puts y
            # puts y.class
            # puts y.interval
            # puts y.date_start
            # puts next_interval

            response.status = 201
            response['Location'] = "#{@proj_route}/#{proj_id}/request"
            { message: 'Request saved', data: req }.to_json
          rescue StandardError # => error
            # puts "ERROR: #{error.inspect}"
            # puts error.backtrace
            routing.halt 404, { message: 'Project not found' }.to_json
          end
        end

        # GET api/v1/projects/[proj_id]
        routing.get do
          # account = Account.first(username: 'agoeng.bhimasta')
          account = Account.first(username: @auth_account['username'])
          project = Project.first(id: proj_id)
          policy = ProjectPolicy.new(account, project)
          raise unless policy.can_view?
          project.full_details
                 .merge(policies: policy.summary)
                 .to_json
        rescue StandardError # => error
          # puts "ERROR: #{error.inspect}"
          # puts error.backtrace
          routing.halt 404, { message: 'Project not found' }.to_json
        end
      end

      # GET api/v1/projects
      routing.get do
        # account = Account.first(username: 'agoeng.bhimasta')
        account = Account.first(username: @auth_account['username'])
        projects_scope = ProjectPolicy::AccountScope.new(account)
        viewable_projects = projects_scope.viewable
        project_list = Projects.new(viewable_projects, account)
        project_list.to_json
        # JSON.pretty_generate(proj)
      rescue StandardError # => error
        # puts "ERROR: #{error.inspect}"
        # puts error.backtrace
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
        response['Location'] = @proj_route.to_s
        { message: 'Project saved', data: new_proj }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError # => error
        # puts "ERROR: #{error.inspect}"
        # puts error.backtrace
        routing.halt 500, { message: error.message }.to_json
      end
    end
  end
end
