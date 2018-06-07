# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('projects') do |routing|
      @proj_route = "#{@api_root}/projects"
      
      routing.on String do |proj_id|
        # GET api/v1/projects/[proj_id]
        routing.get do
          account = Account.first(username: @auth_account['username'])
          project = Project.first(id: proj_id)
          policy  = ProjectPolicy.new(account, project)
          raise unless policy.can_view?

          project.full_details
                 .merge(policies: policy.summary)
                 .to_json
        rescue StandardError
          routing.halt 404, { message: 'Project not found' }.to_json
        end
      end
            
      # GET api/v1/projects
      routing.get do
        # output = { data: Project.all }
        # JSON.pretty_generate(output)
        account = Account.first(username: @auth_account['username'])
        projects_scope = ProjectPolicy::AccountScope.new(account)
        viewable_projects = projects_scope.viewable
        
        JSON.pretty_generate(viewable_projects)
      rescue StandardError
        routing.halt 403, { message: 'Could not find projects' }.to_json
      end
    end
  end
end
