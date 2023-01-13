# frozen_string_literal: true

require_relative 'request_helper'

module Stytch
  class MagicLinks
    include Stytch::RequestHelper

    attr_reader :email

    PATH = '/v1/magic_links'

    def initialize(connection)
      @connection = connection

      @email = Stytch::MagicLinks::Email.new(@connection)
    end

    def create(
      user_id:,
      expiration_minutes: nil,
      attributes: {}
    )
      request = {
        user_id: user_id
      }

      request[:expiration_minutes] = expiration_minutes unless expiration_minutes.nil?
      request[:attributes] = attributes if attributes != {}

      post_request(PATH, request)
    end

    def authenticate(
      token:,
      attributes: {},
      options: {},
      session_token: nil,
      session_jwt: nil,
      session_duration_minutes: nil,
      session_custom_claims: nil,
      code_verifier: nil
    )
      request = {
        token: token
      }

      request[:attributes] = attributes if attributes != {}
      request[:options] = options if options != {}
      request[:session_token] = session_token unless session_token.nil?
      request[:session_jwt] = session_jwt unless session_jwt.nil?
      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
      request[:session_custom_claims] = session_custom_claims unless session_custom_claims.nil?
      request[:code_verifier] = code_verifier unless code_verifier.nil?

      post_request("#{PATH}/authenticate", request)
    end

    class Email
      include Stytch::RequestHelper

      PATH = "#{Stytch::MagicLinks::PATH}/email"

      def initialize(connection)
        @connection = connection
      end

      def send(
        email:,
        login_magic_link_url: nil,
        signup_magic_link_url: nil,
        login_expiration_minutes: nil,
        signup_expiration_minutes: nil,
        attributes: {},
        code_challenge: nil,
        user_id: nil,
        session_token: nil,
        session_jwt: nil,
        locale: nil,
        login_template_id: nil,
        signup_template_id: nil,
      )
        request = {
          email: email
        }

        request[:login_magic_link_url] = login_magic_link_url unless login_magic_link_url.nil?
        request[:signup_magic_link_url] = signup_magic_link_url unless signup_magic_link_url.nil?
        request[:login_expiration_minutes] = login_expiration_minutes unless login_expiration_minutes.nil?
        request[:signup_expiration_minutes] = signup_expiration_minutes unless signup_expiration_minutes.nil?
        request[:attributes] = attributes if attributes != {}
        request[:code_challenge] = code_challenge unless code_challenge.nil?
        request[:user_id] = user_id unless user_id.nil?
        request[:session_token] = session_token unless session_token.nil?
        request[:session_jwt] = session_jwt unless session_jwt.nil?
        request[:locale] = locale unless locale.nil?
        request[:login_template_id] = login_template_id unless login_template_id.nil?
        request[:signup_template_id] = signup_template_id unless signup_template_id.nil?

        post_request("#{PATH}/send", request)
      end

      def login_or_create(
        email:,
        login_magic_link_url: nil,
        signup_magic_link_url: nil,
        login_expiration_minutes: nil,
        signup_expiration_minutes: nil,
        attributes: {},
        create_user_as_pending: false,
        code_challenge: nil,
        locale: nil
        login_template_id: nil,
        signup_template_id: nil,
      )
        request = {
          email: email,
          create_user_as_pending: create_user_as_pending
        }

        request[:login_magic_link_url] = login_magic_link_url unless login_magic_link_url.nil?
        request[:signup_magic_link_url] = signup_magic_link_url unless signup_magic_link_url.nil?
        request[:login_expiration_minutes] = login_expiration_minutes unless login_expiration_minutes.nil?
        request[:signup_expiration_minutes] = signup_expiration_minutes unless signup_expiration_minutes.nil?
        request[:attributes] = attributes if attributes != {}
        request[:code_challenge] = code_challenge unless code_challenge.nil?
        request[:locale] = locale unless locale.nil?
        request[:login_template_id] = login_template_id unless login_template_id.nil?
        request[:signup_template_id] = signup_template_id unless signup_template_id.nil?

        post_request("#{PATH}/login_or_create", request)
      end

      def invite(
        email:,
        invite_magic_link_url: nil,
        invite_expiration_minutes: nil,
        attributes: {},
        name: {},
        locale: nil
        invite_template_id: nil,
      )
        request = {
          email: email
        }

        request[:invite_magic_link_url] = invite_magic_link_url unless invite_magic_link_url.nil?
        request[:invite_expiration_minutes] = invite_expiration_minutes unless invite_expiration_minutes.nil?
        request[:attributes] = attributes if attributes != {}
        request[:name] = name if name != {}
        request[:locale] = locale unless locale.nil?
        request[:invite_template_id] = invite_template_id unless invite_template_id.nil?

        post_request("#{PATH}/invite", request)
      end

      def revoke_invite(
        email:
      )
        request = {
          email: email
        }

        post_request("#{PATH}/revoke_invite", request)
      end
    end
  end
end
