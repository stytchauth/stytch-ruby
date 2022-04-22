# frozen_string_literal: true

require_relative 'request_helper'

module Stytch
  class OAuth
    include Stytch::RequestHelper

    PATH = '/v1/oauth'

    def initialize(connection)
      @connection = connection
    end

    def authenticate(
      token:,
      session_token: nil,
      session_jwt: nil,
      session_duration_minutes: nil
    )
      request = {
        token: token
      }
      request[:session_token] = session_token unless session_token.nil?
      request[:session_jwt] = session_jwt unless session_jwt.nil?
      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?

      post_request("#{PATH}/authenticate", request)
    end
  end
end
