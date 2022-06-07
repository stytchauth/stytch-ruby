# frozen_string_literal: true

require_relative 'request_helper'

module Stytch
  class Passwords
    include Stytch::RequestHelper

    PATH = '/v1/passwords'

    def initialize(connection)
      @connection = connection
    end

    def create(
      email:,
      password:,
      session_duration_minutes: nil
    )
      request = {
        email: email,
        password: password
      }

      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?

      post_request(PATH.to_s, request)
    end

    def authenticate(
      email:,
      password:,
      session_token: nil,
      session_jwt: nil,
      session_duration_minutes: nil
    )
      request = {
        email: email,
        password: password
      }

      request[:session_token] = session_token unless session_token.nil?
      request[:session_jwt] = session_jwt unless session_jwt.nil?
      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?

      post_request("#{PATH}/authenticate", request)
    end

    def email_reset_start(
      email:,
      reset_password_redirect_url: nil,
      reset_password_expiration_minutes: nil,
      code_challenge: nil
    )
      request = {
        email: email
      }

      request[:reset_password_redirect_url] = reset_password_redirect_url unless reset_password_redirect_url.nil?
      unless reset_password_expiration_minutes.nil?
        request[:reset_password_expiration_minutes] =
          reset_password_expiration_minutes
      end
      request[:code_challenge] = code_challenge unless code_challenge.nil?

      post_request("#{PATH}/email/reset/start", request)
    end

    def email_reset(
      token:,
      password:,
      session_token: nil,
      session_jwt: nil,
      session_duration_minutes: nil,
      code_verifier: nil
    )
      request = {
        token: token,
        password: password
      }

      request[:session_token] = session_token unless session_token.nil?
      request[:session_jwt] = session_jwt unless session_jwt.nil?
      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
      request[:code_verifier] = code_verifier unless code_verifier.nil?

      post_request("#{PATH}/email/reset", request)
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
  end
end
