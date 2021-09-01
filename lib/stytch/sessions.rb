# frozen_string_literal: true

require_relative 'request_helper'

module Stytch
  class Sessions
    include Stytch::RequestHelper

    PATH = '/v1/sessions'

    def initialize(connection)
      @connection = connection
    end

    def get(user_id:)
      query_params = {
        user_id: user_id
      }

      request = request_with_query_params(PATH, query_params)

      get_request(request)
    end

    def authenticate(
      session_token:,
      session_duration_minutes: nil
    )
      request = {
        session_token: session_token
      }

      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?

      post_request("#{PATH}/authenticate", request)
    end

    def revoke(
      session_id: nil,
      session_token: nil
    )
      request = {}

      request[:session_id] = session_id unless session_id.nil?
      request[:session_token] = session_token unless session_token.nil?

      post_request("#{PATH}/revoke", request)
    end
  end
end
