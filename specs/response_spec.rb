# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Response Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    SecureMessage.setup(app.config)
    account_data = DATA[:accounts][1]
    @account = Dada::EmailAccount.create(account_data)
    credentials = { username: account_data['username'],
                    password: account_data['password'] }
    signed_credentials = SecureMessage.sign(credentials)
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/auth/authenticate/email_account', signed_credentials.to_json, req_header
    result = JSON.parse(last_response.body)
    @auth_token = "Bearer #{result['auth_token']}"
    @req_header = { 'CONTENT_TYPE' => 'application/json',
                    'HTTP_AUTHORIZATION' => @auth_token }

    DATA[:projects].each do |project_data|
      Dada::CreateProjectForOwner.call(
        owner_id: @account.id, project_data: project_data
      )
    end

    @proj = Dada::Project.first
    DATA[:requests].each do |req_data|
      Dada::CreateRequestForProject.call(
        project_id: @proj.id, request_data: req_data
      )
    end
end

  describe 'Getting Response' do
    before do
      @req = Dada::Request.first
      DATA[:responses].each do |res_data|
        Dada::CreateResponseForRequest.call(
          request_id: @req.id,
          response_data: res_data
        )
      end
    end

    it 'HAPPY: should be able to get list of all requests' do
      get "api/v1/requests/#{@req.id}/responses", nil, @req_header
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['responses'].count).must_equal DATA[:responses].count
    end

    it 'HAPPY: should be able to get details of a single request' do
      res = Dada::Response.first

      get "/api/v1/responses/#{res.id}", nil, @req_header
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['id']).must_equal res.id
      _(result['body']).must_equal res.body
    end

    it 'SAD: should return error if unknown responses requested' do
      get '/api/v1/responses/foobar', nil, @req_header

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating New Response' do
    before do
      @req = Dada::Request.first
      @res_data = DATA[:responses][1]
    end

    it 'HAPPY: should be able to create new request' do
      post "api/v1/requests/#{@req.id}/response",
           @res_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']
      res = Dada::Response.first

      _(created['id']).must_equal res.id
      _(created['header']).must_equal @res_data['header']
      _(created['body']).must_equal @res_data['body']
    end

    it 'BAD: should not create response with illegal attributes' do
      bad_data = @res_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/requests/#{@req.id}/response",
           bad_data.to_json, @req_header
      _(last_response.status).must_equal 404
      _(last_response.header['Location']).must_be_nil
    end
  end
end
