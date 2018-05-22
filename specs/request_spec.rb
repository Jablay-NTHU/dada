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

  describe 'Getting Request' do
    before do
      @proj = Dada::Project.first
      DATA[:requests].each do |req_data|
        Dada::CreateRequestForProject.call(
          project_id: @proj.id,
          request_data: req_data
        )
      end
    end

    it 'HAPPY: should be able to get list of all requests' do
      get "api/v1/project/#{@proj.id}/requests"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result.count).must_equal DATA[:requests].count
    end

    it 'HAPPY: should be able to get details of a single request' do
      req = Dada::Request.first

      get "/api/v1/project/#{@proj.id}/request/#{req.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal req.id
      _(result['data']['attributes']['api_url']).must_equal req.api_url
    end

    it 'SAD: should return error if unknown document requested' do
      proj = Dada::Project.first

      get "/api/v1/project/#{proj.id}/request/foobar"
      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating New Requests' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @proj = Dada::Project.first
      @req_data = DATA[:requests][1]
    end

    it 'HAPPY: should be able to create new request' do
      post "api/v1/project/#{@proj.id}/request",
           @req_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      req = Dada::Request.first

      _(created['id']).must_equal req.id
      _(created['api_url']).must_equal @req_data['api_url']
      _(created['interval']).must_equal @req_data['interval']
    end

    it 'BAD: should not create request with illegal attributes' do
      bad_data = @req_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/project/#{@proj.id}/request",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
