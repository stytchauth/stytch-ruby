# frozen_string_literal: true

require_relative 'request_helper'

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
        intermediate_session_token:,
        organization_id:,
        session_duration_minutes: nil,
        session_custom_claims: nil
      )
        request = {
          intermediate_session_token: intermediate_session_token,
          organization_id: organization_id
        }
        request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
        request[:session_custom_claims] = session_custom_claims unless session_custom_claims.nil?

        post_request('/v1/b2b/discovery/intermediate_sessions/exchange', request)
      end
    end

    class Organizations
      include Stytch::RequestHelper

      def initialize(connection)
        @connection = connection
      end

      def create(
        intermediate_session_token:,
        organization_name:,
        organization_slug:,
        session_duration_minutes: nil,
        session_custom_claims: nil,
        organization_logo_url: nil,
        trusted_metadata: nil,
        sso_jit_provisioning: nil,
        email_allowed_domains: nil,
        email_jit_provisioning: nil,
        email_invites: nil,
        auth_methods: nil,
        allowed_auth_methods: nil
      )
        request = {
          intermediate_session_token: intermediate_session_token,
          organization_name: organization_name,
          organization_slug: organization_slug
        }
        request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
        request[:session_custom_claims] = session_custom_claims unless session_custom_claims.nil?
        request[:organization_logo_url] = organization_logo_url unless organization_logo_url.nil?
        request[:trusted_metadata] = trusted_metadata unless trusted_metadata.nil?
        request[:sso_jit_provisioning] = sso_jit_provisioning unless sso_jit_provisioning.nil?
        request[:email_allowed_domains] = email_allowed_domains unless email_allowed_domains.nil?
        request[:email_jit_provisioning] = email_jit_provisioning unless email_jit_provisioning.nil?
        request[:email_invites] = email_invites unless email_invites.nil?
        request[:auth_methods] = auth_methods unless auth_methods.nil?
        request[:allowed_auth_methods] = allowed_auth_methods unless allowed_auth_methods.nil?

        post_request('/v1/b2b/discovery/organizations/create', request)
      end

      def list(
        intermediate_session_token: nil,
        session_token: nil,
        session_jwt: nil
      )
        request = {}
        request[:intermediate_session_token] = intermediate_session_token unless intermediate_session_token.nil?
        request[:session_token] = session_token unless session_token.nil?
        request[:session_jwt] = session_jwt unless session_jwt.nil?

        post_request('/v1/b2b/discovery/organizations', request)
      end
    end
  end
end
