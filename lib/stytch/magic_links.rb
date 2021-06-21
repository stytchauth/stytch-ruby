require_relative 'request_helper'

module Stytch
  class MagicLinks
    include Stytch::RequestHelper

    attr_reader :email

    PATH = "/v1/magic_links".freeze

    def initialize(connection)
      @connection = connection

      @email = Stytch::MagicLinks::Email.new(@connection)
    end

    def authenticate(
      token:,
      attributes: {},
      options: {}
    )
      request = {
        token: token,
      }

      request[:attributes] = attributes if attributes != {}
      request[:options] = options if options != {}

      post_request("#{PATH}/authenticate", request)
    end

    class Email < self
      PATH = (PATH + "/email").freeze

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
          signup_magic_link_url: signup_magic_link_url,
        }

        request[:login_expiration_minutes] = login_expiration_minutes if login_expiration_minutes != nil
        request[:signup_expiration_minutes] = signup_expiration_minutes if signup_expiration_minutes != nil
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
          create_user_as_pending: create_user_as_pending,
        }

        request[:login_expiration_minutes] = login_expiration_minutes if login_expiration_minutes != nil
        request[:signup_expiration_minutes] = signup_expiration_minutes if signup_expiration_minutes != nil
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
          invite_magic_link_url: invite_magic_link_url,
        }

        request[:invite_expiration_minutes] = invite_expiration_minutes if invite_expiration_minutes != nil
        request[:attributes] = attributes if attributes != {}
        request[:name] = name if name != {}

        post_request("#{PATH}/invite", request)
      end

      def revoke_invite(
        email:
      )
        request = {
          email: email,
        }

        post_request("#{PATH}/revoke_invite", request)
      end
    end
  end
end
