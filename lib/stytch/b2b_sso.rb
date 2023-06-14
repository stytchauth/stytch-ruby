# frozen_string_literal: true

require_relative 'request_helper'

module StytchB2B
  class SSO
    include Stytch::RequestHelper
    attr_reader :oidc, :saml

    def initialize(connection)
      @connection = connection

      @oidc = StytchB2B::SSO::OIDC.new(@connection)
      @saml = StytchB2B::SSO::SAML.new(@connection)
    end

    def get_connections(
      organization_id:
    )
      query_params = {}
      request = request_with_query_params("/v1/b2b/sso/#{organization_id}", query_params)
      get_request(request)
    end

    def delete_connection(
      organization_id:,
      connection_id:
    )
      delete_request("/v1/b2b/sso/#{organization_id}/connections/#{connection_id}")
    end

    def authenticate(
      sso_token:,
      pkce_code_verifier: nil,
      session_token: nil,
      session_jwt: nil,
      session_duration_minutes: nil,
      session_custom_claims: nil
    )
      request = {
        sso_token: sso_token
      }
      request[:pkce_code_verifier] = pkce_code_verifier unless pkce_code_verifier.nil?
      request[:session_token] = session_token unless session_token.nil?
      request[:session_jwt] = session_jwt unless session_jwt.nil?
      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
      request[:session_custom_claims] = session_custom_claims unless session_custom_claims.nil?

      post_request('/v1/b2b/sso/authenticate', request)
    end

    class OIDC
      include Stytch::RequestHelper

      def initialize(connection)
        @connection = connection
      end

      def create_connection(
        organization_id:,
        display_name: nil
      )
        request = {
          organization_id: organization_id
        }
        request[:display_name] = display_name unless display_name.nil?

        post_request("/v1/b2b/sso/oidc/#{organization_id}", request)
      end

      def update_connection(
        organization_id:,
        connection_id:,
        display_name: nil,
        client_id: nil,
        client_secret: nil,
        issuer: nil,
        authorization_url: nil,
        token_url: nil,
        userinfo_url: nil,
        jwks_url: nil
      )
        request = {
          organization_id: organization_id,
          connection_id: connection_id
        }
        request[:display_name] = display_name unless display_name.nil?
        request[:client_id] = client_id unless client_id.nil?
        request[:client_secret] = client_secret unless client_secret.nil?
        request[:issuer] = issuer unless issuer.nil?
        request[:authorization_url] = authorization_url unless authorization_url.nil?
        request[:token_url] = token_url unless token_url.nil?
        request[:userinfo_url] = userinfo_url unless userinfo_url.nil?
        request[:jwks_url] = jwks_url unless jwks_url.nil?

        put_request("/v1/b2b/sso/oidc/#{organization_id}/connections/#{connection_id}", request)
      end
    end

    class SAML
      include Stytch::RequestHelper

      def initialize(connection)
        @connection = connection
      end

      def create_connection(
        organization_id:,
        display_name: nil
      )
        request = {
          organization_id: organization_id
        }
        request[:display_name] = display_name unless display_name.nil?

        post_request("/v1/b2b/sso/saml/#{organization_id}", request)
      end

      def update_connection(
        organization_id:,
        connection_id:,
        idp_entity_id: nil,
        display_name: nil,
        attribute_mapping: nil,
        x509_certificate: nil,
        idp_sso_url: nil
      )
        request = {
          organization_id: organization_id,
          connection_id: connection_id
        }
        request[:idp_entity_id] = idp_entity_id unless idp_entity_id.nil?
        request[:display_name] = display_name unless display_name.nil?
        request[:attribute_mapping] = attribute_mapping unless attribute_mapping.nil?
        request[:x509_certificate] = x509_certificate unless x509_certificate.nil?
        request[:idp_sso_url] = idp_sso_url unless idp_sso_url.nil?

        put_request("/v1/b2b/sso/saml/#{organization_id}/connections/#{connection_id}", request)
      end

      def delete_verification_certificate(
        organization_id:,
        connection_id:,
        certificate_id:
      )
        delete_request("/v1/b2b/sso/saml/#{organization_id}/connections/#{connection_id}/verification_certificates/#{certificate_id}")
      end
    end
  end
end
