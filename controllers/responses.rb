# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('responses') do |routing|
      @res_route = "#{@api_root}/responses"

      # GET api/v1/responses/[res_id]
      routing.get(String) do |res_id|
        # account = Account.first(username: 'agoeng.bhimasta')
        account = Account.first(username: @auth_account['username'])
        response = Response.where(id: res_id).first
        policy = ResponsePolicy.new(account, response)
        raise unless policy.can_view?
        response ? response.to_json : raise
      rescue StandardError => error
        puts "ERROR: #{error.inspect}"
        puts error.backtrace
        routing.halt 404, { message: 'Response not found' }.to_json
      end
    end
  end
end
