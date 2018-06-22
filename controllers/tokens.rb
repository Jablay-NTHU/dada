# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('tokens') do |routing|
      @tok_route = "#{@api_root}/tokens"

      # GET api/v1/tokens/[tok_id]
      routing.on String do |tok_id|
        routing.get do
          # account = Account.first(username: 'agoeng.bhimasta')
          account = Account.first(username: @auth_account['username'])
          token = Token.first(id: tok_id)
          policy = TokenPolicy.new(account, token)
          # JSON.pretty_generate(token.full_details)
          raise unless policy.can_view?
          token.full_details
               .merge(policies: policy.summary)
               .to_json
        rescue StandardError # => error
          # puts "ERROR: #{error.inspect}"
          # puts error.backtrace
          routing.halt 404, { message: 'Token not found' }.to_json
        end
      end

      # GET api/v1/tokens
      routing.get do
        # account = Account.first(username: 'agoeng.bhimasta')
        account = Account.first(username: @auth_account['username'])
        tokens_scope = TokenPolicy::AccountScope.new(account)
        viewable_tokens = tokens_scope.viewable
        JSON.pretty_generate(viewable_tokens)
      rescue StandardError # => error
        # puts "ERROR: #{error.inspect}"
        # puts error.backtrace
        routing.halt 403, { message: 'Could not find tokens' }.to_json
      end
    end
  end
end
