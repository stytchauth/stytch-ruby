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

      post_request(PATH.to_s, request)
    end

    def authenticate(
      token:,
      attributes: {},
      options: {},
      session_token: nil,
      session_duration_minutes: nil
    )
      request = {
        token: token
      }

      request[:attributes] = attributes if attributes != {}
      request[:options] = options if options != {}
      request[:session_token] = session_token unless session_token.nil?
      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?

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
        login_magic_link_url:,
        signup_magic_link_url:,
        login_expiration_minutes: nil,
        signup_expiration_minutes: nil,
        attributes: {}
      )
        request = {
          email: email,
          login_magic_link_url: login_magic_link_url,
          signup_magic_link_url: signup_magic_link_url
        }

        request[:login_expiration_minutes] = login_expiration_minutes unless login_expiration_minutes.nil?
        request[:signup_expiration_minutes] = signup_expiration_minutes unless signup_expiration_minutes.nil?
        request[:attributes] = attributes if attributes != {}

        post_request("#{PATH}/send", request)
      end

      def login_or_create(
        email:,
        login_magic_link_url:,
        signup_magic_link_url:,
        login_expiration_minutes: nil,
        signup_expiration_minutes: nil,
        attributes: {},
        create_user_as_pending: false
      )
        request = {
          email: email,
          login_magic_link_url: login_magic_link_url,
          signup_magic_link_url: signup_magic_link_url,
          create_user_as_pending: create_user_as_pending
        }

        request[:login_expiration_minutes] = login_expiration_minutes unless login_expiration_minutes.nil?
        request[:signup_expiration_minutes] = signup_expiration_minutes unless signup_expiration_minutes.nil?
        request[:attributes] = attributes if attributes != {}

        post_request("#{PATH}/login_or_create", request)
      end

      def invite(
        email:,
        invite_magic_link_url:,
        invite_expiration_minutes: nil,
        attributes: {},
        name: {}
      )
        request = {
          email: email,
          invite_magic_link_url: invite_magic_link_url
        }

        request[:invite_expiration_minutes] = invite_expiration_minutes unless invite_expiration_minutes.nil?
        request[:attributes] = attributes if attributes != {}
        request[:name] = name if name != {}

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
