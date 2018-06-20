# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Token Handling' do
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

  it 'HAPPY: should be able to get list of all token' do
    Dada::CreateTokenForUser.call(
      owner_id: @account.id, token_data: DATA[:tokens][0]
    )
    Dada::CreateTokenForUser.call(
      owner_id: @account.id, token_data: DATA[:tokens][1]
    )

    get 'api/v1/tokens', nil, @req_header
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result.count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single token' do
    existing_token = DATA[:tokens][1]
    Dada::CreateTokenForUser.call(
      owner_id: @account.id, token_data: DATA[:tokens][1]
    )
    id = Dada::Token.first.id

    get "/api/v1/tokens/#{id}", nil, @req_header
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['id']).must_equal id
    _(result['name']).must_equal existing_token['name']
  end

  it 'SAD: should return error if unknown token requested' do
    get '/api/v1/token/foobar', nil, @req_header
    _(last_response.status).must_equal 404
  end

  # describe 'Creating New Token' do
  #   before do
  #     @req_header = { 'CONTENT_TYPE' => 'application/json' }
  #     @token_Data = DATA[:tokens][1]
  #   end

  #   it 'HAPPY: should be able to create new token' do
  #     post 'api/v1/token', @token_Data.to_json, @req_header
  #     _(last_response.status).must_equal 201
  #     _(last_response.header['Location'].size).must_be :>, 0
  #     # created is response result
  #     created = JSON.parse(last_response.body)['data']['data']['attributes']
  #     token = Dada::Token.first

  #     _(created['id']).must_equal token.id
  #     _(created['name']).must_equal @token_Data['name']
  #     _(created['value']).must_equal @token_Data['value']
  #     _(created['description']).must_equal @token_Data['description']
  #   end

  #   it 'BAD: should not create token with illegal attributes' do
  #     bad_data = @token_Data.clone
  #     bad_data['created_at'] = '1900-01-01'
  #     post 'api/v1/token', bad_data.to_json, @req_header

  #     _(last_response.status).must_equal 400
  #     _(last_response.header['Location']).must_be_nil
  #   end
  # end
end
