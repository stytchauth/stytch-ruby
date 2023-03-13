# frozen_string_literal: true

require 'jwt'
require 'json/jwt'

require_relative 'errors'
require_relative 'request_helper'

module Stytch
  class Sessions
    include Stytch::RequestHelper

    PATH = '/v1/sessions'

    def initialize(connection, project_id)
      @connection = connection
      @project_id = project_id
      @cache_last_update = 0
      @jwks_loader = lambda do |options|
        @cached_keys = nil if options[:invalidate] && @cache_last_update < Time.now.to_i - 300
        @cached_keys ||= begin
          @cache_last_update = Time.now.to_i
          keys = []
          jwks(project_id: @project_id)['keys'].each do |r|
            keys << r
          end
          { keys: keys }
        end
      end
    end

    def get(user_id:)
      query_params = {
        user_id: user_id
      }

      request = request_with_query_params(PATH, query_params)

      get_request(request)
    end

    def authenticate(
      session_token: nil,
      session_jwt: nil,
      session_duration_minutes: nil,
      session_custom_claims: nil
    )
      request = {}

      request[:session_token] = session_token unless session_token.nil?
      request[:session_jwt] = session_jwt unless session_jwt.nil?
      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
      request[:session_custom_claims] = session_custom_claims unless session_custom_claims.nil?

      post_request("#{PATH}/authenticate", request)
    end

    def revoke(
      session_id: nil,
      session_token: nil,
      session_jwt: nil
    )
      request = {}

      request[:session_id] = session_id unless session_id.nil?
      request[:session_token] = session_token unless session_token.nil?
      request[:session_jwt] = session_jwt unless session_jwt.nil?

      post_request("#{PATH}/revoke", request)
    end

    def jwks(project_id:)
      request_path = "#{PATH}/jwks/" + project_id
      get_request(request_path)
    end

    # Parse a JWT and verify the signature. If max_token_age_seconds is unset, call the API directly
    # If max_token_age_seconds is set and the JWT was issued (based on the "iat" claim) less than
    # max_token_age_seconds seconds ago, then just verify locally and don't call the API
    # To force remote validation for all tokens, set max_token_age_seconds to 0 or call authenticate()
    def authenticate_jwt(
      session_jwt,
      max_token_age_seconds: nil,
      session_duration_minutes: nil,
      session_custom_claims: nil
    )
      if max_token_age_seconds == 0
        return authenticate(
          session_jwt: session_jwt,
          session_duration_minutes: session_duration_minutes,
          session_custom_claims: session_custom_claims,
        )
      end

      decoded_jwt = authenticate_jwt_local(session_jwt)
      iat_time = Time.at(decoded_jwt["iat"]).to_datetime
      if iat_time + max_token_age_seconds >= Time.now
        session = marshal_jwt_into_session(decoded_jwt)
        return {"session" => session}
      else
        return authenticate(
          session_jwt: session_jwt,
          session_duration_minutes: session_duration_minutes,
          session_custom_claims: session_custom_claims,
        )
      end
    rescue StandardError
      # JWT could not be verified locally. Check with the Stytch API.
      return authenticate(
        session_jwt: session_jwt,
        session_duration_minutes: session_duration_minutes,
        session_custom_claims: session_custom_claims,
      )
    end

    # Parse a JWT and verify the signature locally (without calling /authenticate in the API)
    # Uses the cached value to get the JWK but if it is unavailable, it calls the get_jwks()
    # function to get the JWK
    # This method never authenticates a JWT directly with the API
    def authenticate_jwt_local(session_jwt)
      issuer = "stytch.com/" + @project_id
      begin
        decoded_token = JWT.decode session_jwt, nil, true,
        { jwks: @jwks_loader, iss: issuer, verify_iss: true, aud: @project_id, verify_aud: true, algorithms: ["RS256"]}
        return decoded_token[0]
      rescue JWT::InvalidIssuerError
        raise JWTInvalidIssuerError
      rescue JWT::InvalidAudError
        raise JWTInvalidAudienceError
      rescue JWT::ExpiredSignature
        raise JWTExpiredSignatureError
      rescue JWT::IncorrectAlgorithm
        raise JWTIncorrectAlgorithmError
      end
    end

    def marshal_jwt_into_session(jwt)
      stytch_claim = "https://stytch.com/session"
      expires_at = jwt[stytch_claim]["expires_at"] || Time.at(jwt["exp"]).to_datetime.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
      return {
        "session_id" => jwt[stytch_claim]["id"],
        "user_id" => jwt["sub"],
        "started_at" => jwt[stytch_claim]["started_at"],
        "last_accessed_at" => jwt[stytch_claim]["last_accessed_at"],
        # For JWTs that include it, prefer the inner expires_at claim.
        "expires_at" => expires_at,
        "attributes" => jwt[stytch_claim]["attributes"],
        "authentication_factors" => jwt[stytch_claim]["authentication_factors"],
      }
    end
  end
end
