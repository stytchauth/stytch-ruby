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
      session_duration_minutes: nil,
      session_custom_claims: nil,
      code_verifier: nil
    )
      request = {
        token: token
      }
      request[:session_token] = session_token unless session_token.nil?
      request[:session_jwt] = session_jwt unless session_jwt.nil?
      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
      request[:session_custom_claims] = session_custom_claims unless session_custom_claims.nil?
      request[:code_verifier] = code_verifier unless code_verifier.nil?

      post_request("#{PATH}/authenticate", request)
    end

    # Send a /v1/oauth/attach request.
    #
    # Exactly one of user_id, session_token, or session_jwt is required.
    def attach(
      provider:,
      user_id: nil,
      session_token: nil,
      session_jwt: nil
    )
      request = {
        provider: provider
      }
      request[:user_id] = user_id unless user_id.nil?
      request[:session_token] = session_token unless session_token.nil?
      request[:session_jwt] = session_jwt unless session_jwt.nil?

      post_request("#{PATH}/attach", request)
    end
  end
end
