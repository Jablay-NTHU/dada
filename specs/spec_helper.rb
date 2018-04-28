ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:responses].delete
  app.DB[:requests].delete
  app.DB[:projects].delete
end

DATA = {}
DATA[:projects] = YAML.safe_load File.read('db/seeds/project_seeds.yml')
DATA[:requests] = YAML.safe_load File.read('db/seeds/request_seeds.yml')
DATA[:responses] = YAML.safe_load File.read('db/seeds/response_seeds.yml')
