# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Request Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:projects].each do |project_data|
      Dada::Project.create(project_data)
    end
  end

  it 'HAPPY: should be able to get list of all requests' do
    proj = Dada::Project.first
    DATA[:requests].each do |req|
      proj.add_request(req)
    end

    get "api/v1/project/#{proj.id}/requests"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single request' do
    req_data = DATA[:requests][1]
    proj = Dada::Project.first
    req = proj.add_request(req_data).save

    get "/api/v1/project/#{proj.id}/request/#{req.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal req.id
    _(result['data']['attributes']['api_url']).must_equal req_data['api_url']
  end

  it 'SAD: should return error if unknown document requested' do
    req = Dada::Project.first
    get "/api/v1/project/#{req.id}/request/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new request' do
    proj = Dada::Project.first
    req_data = DATA[:requests][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/project/#{proj.id}/request",
         req_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    req = Dada::Request.first

    _(created['id']).must_equal req.id
    _(created['api_url']).must_equal req_data['api_url']
    _(created['scheduled']).must_equal req_data['scheduled']
  end
end
