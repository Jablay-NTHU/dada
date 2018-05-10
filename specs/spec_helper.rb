# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  Dada::Account.dataset.destroy
  Dada::Project.dataset.destroy
  Dada::Request.dataset.destroy
  Dada::Response.dataset.destroy
end

DATA = {}
DATA[:accounts] = YAML.safe_load File.read('db/seeds/accounts_seed.yml')
DATA[:projects] = YAML.safe_load File.read('db/seeds/projects_seed.yml')
DATA[:requests] = YAML.safe_load File.read('db/seeds/requests_seed.yml')
DATA[:responses] = YAML.safe_load File.read('db/seeds/responses_seed.yml')
