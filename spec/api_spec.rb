# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app'
require_relative '../models/project'

def app
  Dada::Api
end

DATA = YAML.safe_load File.read('db/seeds/project_seeds.yml')

describe 'Test Dada Web API' do
  include Rack::Test::Methods

  before do
    Dir.glob('db/*.txt').each { |filename| FileUtils.rm(filename) }
  end

  # it 'should find the root route' do
  #   get '/'
  #   _(last_response.status).must_equal 200
  # end

  describe 'Handle projects' do
    # it 'HAPPY: should be able to get list of all projects' do
    #   Dada::Project.new(DATA[0]).save
    #   Dada::Project.new(DATA[1]).save
    #   Dada::Project.new(DATA[2]).save

    #   get 'api/v1/projects'
    #   result = JSON.parse last_response.body
    #   _(result['project_ids'].count).must_equal 3
    # end

    it 'HAPPY: should be able to get details of a single project' do
      Dada::Project.new(DATA[1]).save
      id = Dir.glob('db/*.txt').first.split(%r{[/\.]})[1]
      get "/api/v1/project/#{id}"
      result = JSON.parse last_response.body
      _(last_response.status).must_equal 200
      _(result['id']).must_equal id
    end

    # it 'SAD: should return error if unknown project requested' do
    #   get '/api/v1/project/foobar'

    #   _(last_response.status).must_equal 404
    # end

    # it 'HAPPY: should be able to create new project' do
    #   req_header = { 'CONTENT_TYPE' => 'application/json' }
    #   post 'api/v1/project', DATA[1].to_json, req_header

    #   _(last_response.status).must_equal 201
    # end
  end
end
