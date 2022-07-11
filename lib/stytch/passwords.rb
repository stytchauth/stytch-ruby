# frozen_string_literal: true

require_relative 'request_helper'

module Stytch
  class Passwords
    include Stytch::RequestHelper

    attr_reader :email

    PATH = '/v1/passwords'

    def initialize(connection)
      @connection = connection

      @email = Stytch::Passwords::Email.new(@connection)
    end

    def create(
      email:,
      password:,
      session_duration_minutes: nil,
      session_custom_claims: nil
    )
      request = {
        email: email,
        password: password
      }

      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
      request[:session_custom_claims] = session_custom_claims unless session_custom_claims.nil?

      post_request(PATH.to_s, request)
    end

    def authenticate(
      email:,
      password:,
      session_token: nil,
      session_jwt: nil,
      session_duration_minutes: nil,
      session_custom_claims: nil
    )
      request = {
        email: email,
        password: password
      }

      request[:session_token] = session_token unless session_token.nil?
      request[:session_jwt] = session_jwt unless session_jwt.nil?
      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
      request[:session_custom_claims] = session_custom_claims unless session_custom_claims.nil?

      post_request("#{PATH}/authenticate", request)
    end

    def strength_check(
      password:,
      email: nil
    )
      request = {
        password: password
      }

      request[:email] = email unless email.nil?

      post_request("#{PATH}/strength_check", request)
    end

    def migrate(
      email:,
      hash:,
      hash_type:,
      prepend_salt: nil,
      append_salt: nil
    )
      request = {
        email: email,
        hash: hash,
        hash_type: hash_type
      }

      request[:prepend_salt] = prepend_salt unless prepend_salt.nil?
      request[:append_salt] = append_salt unless append_salt.nil?

      post_request("#{PATH}/migrate", request)
    end

    class Email
      include Stytch::RequestHelper

      PATH = "#{Stytch::Passwords::PATH}/email"

      def initialize(connection)
        @connection = connection
      end

      def reset_start(
        email:,
        login_redirect_url: nil,
        reset_password_redirect_url: nil,
        login_expiration_minutes: nil,
        reset_password_expiration_minutes: nil,
        attributes: {},
        code_challenge: nil
      )
        request = {
          email: email
        }

        request[:login_redirect_url] = login_redirect_url unless login_redirect_url.nil?
        request[:reset_password_redirect_url] = reset_password_redirect_url unless reset_password_redirect_url.nil?
        request[:login_expiration_minutes] = login_expiration_minutes unless login_expiration_minutes.nil?
        unless reset_password_expiration_minutes.nil?
          request[:reset_password_expiration_minutes] =
            reset_password_expiration_minutes
        end
        request[:attributes] = attributes if attributes != {}
        request[:code_challenge] = code_challenge unless code_challenge.nil?

        post_request("#{PATH}/reset/start", request)
      end

      def reset(
        token:,
        password:,
        session_token: nil,
        session_jwt: nil,
        session_duration_minutes: nil,
        session_custom_claims: nil,
        attributes: {},
        options: {},
        code_verifier: nil
      )
        request = {
          token: token,
          password: password
        }

        request[:session_token] = session_token unless session_token.nil?
        request[:session_jwt] = session_jwt unless session_jwt.nil?
        request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
        request[:session_custom_claims] = session_custom_claims unless session_custom_claims.nil?
        request[:attributes] = attributes if attributes != {}
        request[:options] = options if options != {}
        request[:code_verifier] = code_verifier unless code_verifier.nil?

        post_request("#{PATH}/reset", request)
      end
    end
  end
end
