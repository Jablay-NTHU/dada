# frozen_string_literal: true

require_relative '../lib/secure_message.rb'
require_relative 'spec_helper.rb'
require 'econfig'
require 'http'

describe 'Test Project Handling' do
  extend Econfig::Shortcut
  Econfig.env = 'test'.to_s
  Econfig.root = '.'

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
  end

  it 'HAPPY: should be able to get list of all projects' do
    DATA[:projects].each do |project_data|
      Dada::CreateProjectForOwner.call(
        owner_id: @account.id, project_data: project_data
      )
    end

    get 'api/v1/projects', nil, @req_header
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result.count).must_equal 3
  end

  it 'HAPPY: should be able to get details of a single project' do
    existing_proj = DATA[:projects][1]
    Dada::CreateProjectForOwner.call(
      owner_id: @account.id, project_data: DATA[:projects][1]
    )
    id = Dada::Project.first.id

    get "/api/v1/projects/#{id}", nil, @req_header
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['id']).must_equal id
    _(result['title']).must_equal existing_proj['title']
  end

  it 'SAD: should return error if unknown project requested' do
    get '/api/v1/projects/foobar'
    _(last_response.status).must_equal 404
  end

  describe 'Creating New Projects' do
    before do
      @proj_data = DATA[:projects][2]
    end

    it 'HAPPY: should be able to create new projects' do
      post 'api/v1/projects', @proj_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)
      proj = Dada::Project.first

      _(created['data']['id']).must_equal proj.id
      _(created['data']['title']).must_equal @proj_data['title']
      _(created['data']['description']).must_equal @proj_data['description']
    end

    it 'BAD: should not create project with illegal attributes' do
      bad_data = @proj_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/projects', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
