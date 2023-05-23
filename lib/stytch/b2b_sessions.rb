# frozen_string_literal: true

require_relative "request_helper"

module StytchB2B
  class Sessions
    include Stytch::RequestHelper

    def initialize(connection)
      @connection = connection
    end

    def get(
      organization_id:, member_id:
    )
      query_params = {
        organization_id: organization_id, member_id: member_id,
      }
      request = request_with_query_params("/v1/b2b/sessions", query_params)
      get_request(request)
    end

    def authenticate(
      session_token: nil, session_duration_minutes: nil, session_jwt: nil, session_custom_claims: nil
    )
      request = {}
      request[:session_token] = session_token if session_token != nil
      request[:session_duration_minutes] = session_duration_minutes if session_duration_minutes != nil
      request[:session_jwt] = session_jwt if session_jwt != nil
      request[:session_custom_claims] = session_custom_claims if session_custom_claims != nil

      post_request("/v1/b2b/sessions/authenticate", request)
    end

    def revoke(
      member_session_id: nil, session_token: nil, session_jwt: nil, member_id: nil
    )
      request = {}
      request[:member_session_id] = member_session_id if member_session_id != nil
      request[:session_token] = session_token if session_token != nil
      request[:session_jwt] = session_jwt if session_jwt != nil
      request[:member_id] = member_id if member_id != nil

      post_request("/v1/b2b/sessions/revoke", request)
    end

    def exchange(
      organization_id:, session_token: nil, session_jwt: nil, session_duration_minutes: nil, session_custom_claims: nil
    )
      request = {
        organization_id: organization_id,
      }
      request[:session_token] = session_token if session_token != nil
      request[:session_jwt] = session_jwt if session_jwt != nil
      request[:session_duration_minutes] = session_duration_minutes if session_duration_minutes != nil
      request[:session_custom_claims] = session_custom_claims if session_custom_claims != nil

      post_request("/v1/b2b/sessions/exchange", request)
    end

    def jwks(
      project_id:
    )
      query_params = {
        project_id: project_id,
      }
      request = request_with_query_params("/v1/b2b/sessions/jwks/#{project_id}", query_params)
      get_request(request)
    end
  end
end
