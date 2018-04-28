# frozen_string_literal: true

require 'json'
require 'roda'
require 'base64'

require_relative 'models/experiment'

module Dada
  # Web controller for Dada API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Experiment.setup
    end

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'Dada API up at /api/v1' }.to_json
      end
      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'experiment' do
            # GET api/v1/experiment/[ID]
            routing.get String do |id|
              Experiment.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Experiment not found' }.to_json
            end
            # GET api/v1/experiment
            routing.get do
              output = { experiment_ids: Experiment.all }
              JSON.pretty_generate(output)
            end
            # POST api/v1/experiment
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_exp = Experiment.new(new_data)
              if new_exp.save
                response.status = 201
                { message: 'Experiment saved', id: new_exp.id }.to_json
              else
                routing.halt 400, { message: "Couldn't save project" }.to_json
              end
            end
          end
        end
      end
    end
  end
end
