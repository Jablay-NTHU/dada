# frozen_string_literal: true

require_relative 'project'

module Dada
  # Behaviors of the currently logged in account
  class Projects
    attr_reader :all

    def initialize(projects_list, account)
      @all = projects_list.map do |proj|
        policy = ProjectPolicy.new(account, proj)
        Project.first(id: proj.id)
               .full_details
               .merge(policies: policy.summary)
      end
    end

    def to_json(options = {})
      JSON(@all, options)
    end
  end
end
