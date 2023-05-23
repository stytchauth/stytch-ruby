# frozen_string_literal: true

require_relative "../request_helper"

module Stytch
  class MagicLinks
    include Stytch::RequestHelper
    attr_reader :magic_links, :magic_links

    def initialize(connection)
      @connection = connection

      @email = Stytch::MagicLinks::Email.new(@connection)
      @discovery = Stytch::MagicLinks::Discovery.new(@connection)
    end

    def authenticate(
        magic_links_token: ,
        pkce_code_verifier: nil,
        session_token: nil,
        session_jwt: nil,
        session_duration_minutes: nil,
        session_custom_claims: nil,
    )
      request = {
          magic_links_token: magic_links_token,
      }
      request[:pkce_code_verifier] = pkce_code_verifier if pkce_code_verifier != nil
      request[:session_token] = session_token if session_token != nil
      request[:session_jwt] = session_jwt if session_jwt != nil
      request[:session_duration_minutes] = session_duration_minutes if session_duration_minutes != nil
      request[:session_custom_claims] = session_custom_claims if session_custom_claims != nil

      post_request("/v1/b2b/magic_links/authenticate", request)
    end


    class Email
      include Stytch::RequestHelper
      attr_reader :magic_links

      def initialize(connection)
        @connection = connection

        @discovery = Stytch::MagicLinks::Email::Discovery.new(@connection)
      end

      def login_or_signup(
          organization_id: ,
          email_address: ,
          login_redirect_url: nil,
          signup_redirect_url: nil,
          pkce_code_challenge: nil,
          login_template_id: nil,
          signup_template_id: nil,
          locale: nil,
      )
        request = {
            organization_id: organization_id,
            email_address: email_address,
        }
        request[:login_redirect_url] = login_redirect_url if login_redirect_url != nil
        request[:signup_redirect_url] = signup_redirect_url if signup_redirect_url != nil
        request[:pkce_code_challenge] = pkce_code_challenge if pkce_code_challenge != nil
        request[:login_template_id] = login_template_id if login_template_id != nil
        request[:signup_template_id] = signup_template_id if signup_template_id != nil
        request[:locale] = locale if locale != nil

        post_request("/v1/b2b/magic_links/email/login_or_signup", request)
      end

      def invite(
          organization_id: ,
          email_address: ,
          invite_redirect_url: nil,
          invited_by_member_id: nil,
          name: nil,
          trusted_metadata: nil,
          untrusted_metadata: nil,
          invite_template_id: nil,
          locale: nil,
      )
        request = {
            organization_id: organization_id,
            email_address: email_address,
        }
        request[:invite_redirect_url] = invite_redirect_url if invite_redirect_url != nil
        request[:invited_by_member_id] = invited_by_member_id if invited_by_member_id != nil
        request[:name] = name if name != nil
        request[:trusted_metadata] = trusted_metadata if trusted_metadata != nil
        request[:untrusted_metadata] = untrusted_metadata if untrusted_metadata != nil
        request[:invite_template_id] = invite_template_id if invite_template_id != nil
        request[:locale] = locale if locale != nil

        post_request("/v1/b2b/magic_links/email/invite", request)
      end


      class Discovery
        include Stytch::RequestHelper

        def initialize(connection)
          @connection = connection

        end

        def send(
            email_address: ,
            discovery_redirect_url: nil,
            pkce_code_challenge: nil,
            login_template_id: nil,
            locale: nil,
        )
          request = {
              email_address: email_address,
          }
          request[:discovery_redirect_url] = discovery_redirect_url if discovery_redirect_url != nil
          request[:pkce_code_challenge] = pkce_code_challenge if pkce_code_challenge != nil
          request[:login_template_id] = login_template_id if login_template_id != nil
          request[:locale] = locale if locale != nil

          post_request("/v1/b2b/magic_links/email/discovery/send", request)
        end


      end
    end
    class Discovery
      include Stytch::RequestHelper

      def initialize(connection)
        @connection = connection

      end

      def authenticate(
          discovery_magic_links_token: ,
          pkce_code_verifier: nil,
      )
        request = {
            discovery_magic_links_token: discovery_magic_links_token,
        }
        request[:pkce_code_verifier] = pkce_code_verifier if pkce_code_verifier != nil

        post_request("/v1/b2b/magic_links/discovery/authenticate", request)
      end


    end
  end
end