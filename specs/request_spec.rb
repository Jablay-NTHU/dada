# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Request Handling' do
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
  end

  describe 'Getting Request' do
    before do
      @proj = Dada::Project.first
      DATA[:requests].each do |req_data|
        Dada::CreateRequestForProject.call(
          project_id: @proj.id, request_data: req_data
        )
      end
    end

    it 'HAPPY: should be able to get list of all requests' do
      get "api/v1/projects/#{@proj.id}/requests", nil, @req_header
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['requests'].count).must_equal DATA[:requests].count
    end

    it 'HAPPY: should be able to get details of a single request' do
      req = Dada::Request.first

      get "/api/v1/requests/#{req.id}", nil, @req_header
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['id']).must_equal req.id
      _(result['call_url']).must_equal req.call_url
    end

    it 'SAD: should return error if unknown document requested' do
      get "/api/v1/requests/foobar", nil, @req_header
      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating New Requests' do
    before do
      @proj = Dada::Project.first
      @req_data = DATA[:requests][1]
    end

    it 'HAPPY: should be able to create new request' do
      post "api/v1/projects/#{@proj.id}/request",
           @req_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']
      req = Dada::Request.first

      _(created['id']).must_equal req.id
      _(created['call_url']).must_equal @req_data['call_url']
      _(created['interval']).must_equal @req_data['interval']
    end

    it 'BAD: should not create request with illegal attributes' do
      bad_data = @req_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/projects/#{@proj.id}/request",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 404
      _(last_response.header['Location']).must_be_nil
    end
  end
end
