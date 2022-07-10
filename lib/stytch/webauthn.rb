# frozen_string_literal: true

require_relative 'request_helper'

module Stytch
  class WebAuthn
    include Stytch::RequestHelper

    PATH = '/v1/webauthn'

    def initialize(connection)
      @connection = connection
    end

    def register_start(
      user_id:,
      domain:,
      user_agent: nil,
      authenticator_type: nil
    )
      request = {
        user_id: user_id,
        domain: domain
      }

      request[:user_agent] = user_agent unless user_agent.nil?
      request[:authenticator_type] = authenticator_type unless authenticator_type.nil?

      post_request("#{PATH}/register/start", request)
    end

    def register(
      user_id:,
      public_key_credential:
    )
      request = {
        user_id: user_id,
        public_key_credential: public_key_credential
      }

      post_request("#{PATH}/register", request)
    end

    def authenticate_start(
      user_id:,
      domain:
    )
      request = {
        user_id: user_id,
        domain: domain
      }

      post_request("#{PATH}/authenticate/start", request)
    end

    def authenticate(
      public_key_credential:,
      session_token: nil,
      session_jwt: nil,
      session_duration_minutes: nil,
      session_custom_claims: nil
    )
      request = {
        public_key_credential: public_key_credential
      }

      request[:session_token] = session_token unless session_token.nil?
      request[:session_jwt] = session_jwt unless session_jwt.nil?
      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
      request[:session_custom_claims] = session_custom_claims unless session_custom_claims.nil?

      post_request("#{PATH}/authenticate", request)
    end
  end
end
