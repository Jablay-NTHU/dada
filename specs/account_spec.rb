# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Document Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    SecureMessage.setup(app.config)
  end

  describe 'Account information' do
    it 'HAPPY: should be able to get details of a single project' do
      account_data = DATA[:accounts][1]
      account = Dada::Account.create(account_data)

      get "/api/v1/accounts/#{account.username}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['id']).must_equal account.id
      _(result['username']).must_equal account.username
      _(result['salt']).must_be_nil
      _(result['password']).must_be_nil
      _(result['password_hash']).must_be_nil
    end
  end

  describe 'Account Creation' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @account_data = DATA[:accounts][1]
    end

    it 'HAPPY: should be able to create new email accounts' do
      post 'api/v1/accounts', @account_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']
      account = Dada::EmailAccount.first

      _(created['id']).must_equal account.id
      _(created['username']).must_equal @account_data['username']
      _(created['email']).must_equal @account_data['email']
      _(account.password?(@account_data['password'])).must_equal true
      _(account.password?('not_really_the_password')).must_equal false
    end

    it 'BAD: should not create account with illegal attributes' do
      bad_data = @account_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/accounts', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end

  describe 'Account Authentication' do
    before do
      @account_data = DATA[:accounts][1]
      @account = Dada::Account.create(@account_data)
    end

    it 'HAPPY: should authenticate valid credentials' do
      credentials = { username: @account_data['username'],
                      password: @account_data['password'] }
      signed_credentials = SecureMessage.sign(credentials)
      post 'api/v1/auth/authenticate', signed_credentials.to_json, @req_header

      _(last_response.status).must_equal 200
      auth_account = JSON.parse(last_response.body)
      _(last_response.status).must_equal 200
      _(auth_account['username'].must_equal(@account_data['username']))
      _(auth_account['email'].must_equal(@account_data['email']))
      _(auth_account['id'].must_be_nil)
    end

    it 'BAD: should not authenticate invalid password' do
      credentials = { username: @account_data['username'],
                      password: 'fakepassword' }

      assert_output(/invalid/i, '') do
        post 'api/v1/accounts/authenticate', credentials.to_json, @req_header
      end

      result = JSON.parse(last_response.body)

      _(last_response.status).must_equal 403
      _(result['message']).wont_be_nil
      _(result['username']).must_be_nil
      _(result['email']).must_be_nil
    end
  end
end
