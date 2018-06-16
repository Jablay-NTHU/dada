# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('projects') do |routing|
      @proj_route = "#{@api_root}/projects"
      @account = Account.first(username: 'victorlin12345')
      # @account = Account.first(username: @auth_account['username'])
      routing.on String do |proj_id|
        #@account = Account.first(username: 'victorlin12345')
        project = Project.first(id: proj_id)
        @policy  = ProjectPolicy.new(@account, project)
        routing.on 'request' do
          routing.on String do |req_id|
            # POST /projects/[proj_id]/request/[req_id]/edit
            routing.on 'edit' do
              routing.post do
                puts 'Im here'
                edit_data = JSON.parse(routing.body.read)
                raise unless @policy.can_edit_requests?
                Dada::EditRequest.call(request_id: req_id, edit_data: edit_data)
                response.status = 201
                response['Location'] = "#{@proj_route}/#{proj_id}/request/#{req_id}/edit"
                { message: 'Request edited' }.to_json
              rescue Sequel::MassAssignmentRestriction
                routing.halt 400, { message: 'Illegal Request' }.to_json
              rescue StandardError => error
                puts "ERROR: #{error.inspect}"
                puts error.backtrace
                routing.halt 404, { message: 'Request not found' }.to_json
              end
            end
            
            # POST /projects/[proj_id]/request/[req_id]/delete
            routing.on 'delete' do
              routing.post do
                raise unless @policy.can_remove_requests?
                req = Request.first(id: req_id)
                req.destroy
                response.status = 201
                response['Location'] = "#{@proj_route}/#{proj_id}/request/#{req_id}/delete"
                { message: 'Request deleted' }.to_json
              rescue Sequel::MassAssignmentRestriction
                routing.halt 400, { message: 'Illegal Request' }.to_json
              rescue StandardError => error
                puts "ERROR: #{error.inspect}"
                puts error.backtrace
                routing.halt 404, { message: 'Request not found' }.to_json
              end
            end
          end

          # POST /projects/[proj_id]/request
          routing.post do
            req_data = JSON.parse(routing.body.read)
          raise unless @policy.can_add_requests?
            new_req = Dada::CreateRequestForProject.call(project_id: proj_id, request_data: req_data)
            response.status = 201
            response['Location'] = "#{@proj_route}/#{proj_id}/request"
            { message: 'Request Saved' , data: new_req }.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.halt 500, { message: error.message }.to_json
          end

        end

        # POST api/v1/projects/[proj_id]/delete
        routing.on 'delete' do
          routing.post do
            raise unless @policy.can_delete?
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
            raise unless @policy.can_leave?
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
            raise unless @policy.can_edit?
            project.update(proj_data)
            response.status = 201
            { message: 'Project edited' }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.halt 404, { message: 'Project not found' }.to_json
          end
        end

        # GET api/v1/projects/[proj_id]
        routing.get do
          raise unless @policy.can_view?
          project.full_details
                 .merge(policies: @policy.summary)
                 .to_json
        rescue StandardError => error
          puts "ERROR: #{error.inspect}"
          puts error.backtrace
          routing.halt 404, { message: 'Project not found' }.to_json
        end
      end

      # GET api/v1/projects
      routing.get do
        projects_scope = ProjectPolicy::AccountScope.new(@account)
        viewable_projects = projects_scope.viewable
        proj = Projects.new(viewable_projects, @account)
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
        #@account = Account.first(username: 'victorlin12345')
        project = Project.first(id: proj_id)        
        new_proj = Dada::CreateProjectForOwner.call(
          owner_id: @account.id, project_data: proj_data
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
