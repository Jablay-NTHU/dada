# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('requests') do |routing|
      @req_route = "#{@api_root}/requests"

      # GET api/v1/requests/[req_id]
      routing.get(String) do |req_id|
        # account = Account.first(username: 'agoeng.bhimasta')
        account = Account.first(username: @auth_account['username'])
        request = Request.where(id: req_id).first
        policy = RequestPolicy.new(account, request)
        raise unless policy.can_view?
        request.full_details
               .merge(policies: policy.summary)
               .to_json
      rescue StandardError => error
        puts "ERROR: #{error.inspect}"
        puts error.backtrace
        routing.halt 404, { message: 'Request not found' }.to_json
      end
    end
  end
end
