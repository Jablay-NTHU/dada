# frozen_string_literal: true

require 'roda'

module Dada
  # Web controller for Dada API
  class Api < Roda
    route('requests') do |routing|
      @req_route = "#{@api_root}/requests"

      routing.get(String) do |req_id|
        account = Account.first(username: @auth_account['username'])
        req = Request.where(id: req_id).first
        policy = RequestPolicy.new(account, req)
        raise unless policy.can_view?

        doc ? doc.to_json : raise
      rescue StandardError
        routing.halt 404, { message: 'Request not found' }.to_json
      end
    end
  end
end
