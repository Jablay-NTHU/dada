# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Project Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all projects' do
    Dada::Project.create(DATA[:projects][0]).save
    Dada::Project.create(DATA[:projects][1]).save
    Dada::Project.create(DATA[:projects][2]).save

    get 'api/v1/projects'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 3
  end

  it 'HAPPY: should be able to get details of a single project' do
    existing_proj = DATA[:projects][1]
    Dada::Project.create(existing_proj).save
    id = Dada::Project.first.id

    get "/api/v1/project/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['title']).must_equal existing_proj['title']
  end

  it 'SAD: should return error if unknown project requested' do
    get '/api/v1/project/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new projects' do
    existing_proj = DATA[:projects][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/project', existing_proj.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    proj = Dada::Project.first

    _(created['id']).must_equal proj.id
    _(created['title']).must_equal existing_proj['title']
    _(created['description']).must_equal existing_proj['description']
  end
end
