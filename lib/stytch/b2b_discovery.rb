# frozen_string_literal: true

require_relative "request_helper"

module StytchB2B
  class Discovery
    include Stytch::RequestHelper
    attr_reader :intermediate_sessions, :organizations

    def initialize(connection)
      @connection = connection

      @intermediate_sessions = StytchB2B::Discovery::IntermediateSessions.new(@connection)
      @organizations = StytchB2B::Discovery::Organizations.new(@connection)
    end

    class IntermediateSessions
      include Stytch::RequestHelper

      def initialize(connection)
        @connection = connection
      end

      def exchange(
        intermediate_session_token:, organization_id:, session_duration_minutes: nil, session_custom_claims: nil
      )
        request = {
          intermediate_session_token: intermediate_session_token, organization_id: organization_id,
        }
        request[:session_duration_minutes] = session_duration_minutes if session_duration_minutes != nil
        request[:session_custom_claims] = session_custom_claims if session_custom_claims != nil

        post_request("/v1/b2b/discovery/intermediate_sessions/exchange", request)
      end
    end

    class Organizations
      include Stytch::RequestHelper

      def initialize(connection)
        @connection = connection
      end

      def create(
        intermediate_session_token:, organization_name:, organization_slug:, organization_logo_url:, email_allowed_domains:, allowed_auth_methods:, session_duration_minutes: nil, session_custom_claims: nil, trusted_metadata: nil, sso_jit_provisioning: nil, email_jit_provisioning: nil, email_invites: nil, auth_methods: nil
      )
        request = {
          intermediate_session_token: intermediate_session_token, organization_name: organization_name, organization_slug: organization_slug, organization_logo_url: organization_logo_url, email_allowed_domains: email_allowed_domains, allowed_auth_methods: allowed_auth_methods,
        }
        request[:session_duration_minutes] = session_duration_minutes if session_duration_minutes != nil
        request[:session_custom_claims] = session_custom_claims if session_custom_claims != nil
        request[:trusted_metadata] = trusted_metadata if trusted_metadata != nil
        request[:sso_jit_provisioning] = sso_jit_provisioning if sso_jit_provisioning != nil
        request[:email_jit_provisioning] = email_jit_provisioning if email_jit_provisioning != nil
        request[:email_invites] = email_invites if email_invites != nil
        request[:auth_methods] = auth_methods if auth_methods != nil

        post_request("/v1/b2b/discovery/organizations/create", request)
      end

      def list(
        intermediate_session_token: nil, session_token: nil, session_jwt: nil
      )
        request = {}
        request[:intermediate_session_token] = intermediate_session_token if intermediate_session_token != nil
        request[:session_token] = session_token if session_token != nil
        request[:session_jwt] = session_jwt if session_jwt != nil

        post_request("/v1/b2b/discovery/organizations", request)
      end
    end
  end
end
