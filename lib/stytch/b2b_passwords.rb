# frozen_string_literal: true

require_relative 'request_helper'

module StytchB2B
  class Passwords
    include Stytch::RequestHelper
    attr_reader :email, :sessions, :existing_password

    def initialize(connection)
      @connection = connection

      @email = StytchB2B::Passwords::Email.new(@connection)
      @sessions = StytchB2B::Passwords::Sessions.new(@connection)
      @existing_password = StytchB2B::Passwords::ExistingPassword.new(@connection)
    end

    def strength_check(
      password:,
      email_address: nil
    )
      request = {
        password: password
      }
      request[:email_address] = email_address unless email_address.nil?

      post_request('/v1/b2b/passwords/strength_check', request)
    end

    def migrate(
      email_address:,
      hash:,
      hash_type:,
      organization_id:,
      name:,
      md_5_config: nil,
      argon_2_config: nil,
      sha_1_config: nil,
      scrypt_config: nil,
      trusted_metadata: nil,
      untrusted_metadata: nil
    )
      request = {
        email_address: email_address,
        hash: hash,
        hash_type: hash_type,
        organization_id: organization_id,
        name: name
      }
      request[:md_5_config] = md_5_config unless md_5_config.nil?
      request[:argon_2_config] = argon_2_config unless argon_2_config.nil?
      request[:sha_1_config] = sha_1_config unless sha_1_config.nil?
      request[:scrypt_config] = scrypt_config unless scrypt_config.nil?
      request[:trusted_metadata] = trusted_metadata unless trusted_metadata.nil?
      request[:untrusted_metadata] = untrusted_metadata unless untrusted_metadata.nil?

      post_request('/v1/b2b/passwords/migrate', request)
    end

    def authenticate(
      organization_id:,
      email_address:,
      password:,
      session_token: nil,
      session_duration_minutes: nil,
      session_jwt: nil,
      session_custom_claims: nil
    )
      request = {
        organization_id: organization_id,
        email_address: email_address,
        password: password
      }
      request[:session_token] = session_token unless session_token.nil?
      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
      request[:session_jwt] = session_jwt unless session_jwt.nil?
      request[:session_custom_claims] = session_custom_claims unless session_custom_claims.nil?

      post_request('/v1/b2b/passwords/authenticate', request)
    end

    class Email
      include Stytch::RequestHelper

      def initialize(connection)
        @connection = connection
      end

      def reset_start(
        organization_id:,
        email_address:,
        reset_password_redirect_url:,
        login_redirect_url:,
        reset_password_expiration_minutes: nil,
        code_challenge: nil,
        locale: nil,
        reset_password_template_id: nil
      )
        request = {
          organization_id: organization_id,
          email_address: email_address,
          reset_password_redirect_url: reset_password_redirect_url,
          login_redirect_url: login_redirect_url
        }
        unless reset_password_expiration_minutes.nil?
          request[:reset_password_expiration_minutes] =
            reset_password_expiration_minutes
        end
        request[:code_challenge] = code_challenge unless code_challenge.nil?
        request[:locale] = locale unless locale.nil?
        request[:reset_password_template_id] = reset_password_template_id unless reset_password_template_id.nil?

        post_request('/v1/b2b/passwords/email/reset/start', request)
      end

      def reset(
        password_reset_token:,
        password:,
        session_token: nil,
        session_duration_minutes: nil,
        session_jwt: nil,
        code_verifier: nil,
        session_custom_claims: nil
      )
        request = {
          password_reset_token: password_reset_token,
          password: password
        }
        request[:session_token] = session_token unless session_token.nil?
        request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
        request[:session_jwt] = session_jwt unless session_jwt.nil?
        request[:code_verifier] = code_verifier unless code_verifier.nil?
        request[:session_custom_claims] = session_custom_claims unless session_custom_claims.nil?

        post_request('/v1/b2b/passwords/email/reset', request)
      end
    end

    class Sessions
      include Stytch::RequestHelper

      def initialize(connection)
        @connection = connection
      end

      def reset(
        organization_id:,
        password:,
        session_token: nil,
        session_jwt: nil
      )
        request = {
          organization_id: organization_id,
          password: password
        }
        request[:session_token] = session_token unless session_token.nil?
        request[:session_jwt] = session_jwt unless session_jwt.nil?

        post_request('/v1/b2b/passwords/session/reset', request)
      end
    end

    class ExistingPassword
      include Stytch::RequestHelper

      def initialize(connection)
        @connection = connection
      end

      def reset(
        email_address:,
        existing_password:,
        new_password:,
        organization_id:,
        session_token: nil,
        session_duration_minutes: nil,
        session_jwt: nil,
        session_custom_claims: nil
      )
        request = {
          email_address: email_address,
          existing_password: existing_password,
          new_password: new_password,
          organization_id: organization_id
        }
        request[:session_token] = session_token unless session_token.nil?
        request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
        request[:session_jwt] = session_jwt unless session_jwt.nil?
        request[:session_custom_claims] = session_custom_claims unless session_custom_claims.nil?

        post_request('/v1/b2b/passwords/existing_password/reset', request)
      end
    end
  end
end
