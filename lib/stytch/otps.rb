# frozen_string_literal: true

require_relative 'request_helper'

module Stytch
  class OTPs
    include Stytch::RequestHelper

    attr_reader :sms, :whatsapp, :email

    PATH = '/v1/otps'

    def initialize(connection)
      @connection = connection

      @sms = Stytch::OTPs::SMS.new(@connection)
      @whatsapp = Stytch::OTPs::WhatsApp.new(@connection)
      @email = Stytch::OTPs::Email.new(@connection)
    end

    def authenticate(
      method_id:,
      code:,
      attributes: {},
      options: {},
      session_token: nil,
      session_jwt: nil,
      session_duration_minutes: nil,
      session_custom_claims: nil
    )
      request = {
        method_id: method_id,
        code: code
      }

      request[:attributes] = attributes if attributes != {}
      request[:options] = options if options != {}
      request[:session_token] = session_token unless session_token.nil?
      request[:session_jwt] = session_jwt unless session_jwt.nil?
      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
      request[:session_custom_claims] = session_custom_claims unless session_custom_claims.nil?

      post_request("#{PATH}/authenticate", request)
    end

    class SMS
      include Stytch::RequestHelper

      PATH = "#{Stytch::OTPs::PATH}/sms"

      def initialize(connection)
        @connection = connection
      end

      def send(
        phone_number:,
        expiration_minutes: nil,
        attributes: {},
        user_id: nil,
        session_token: nil,
        session_jwt: nil,
      )
        request = {
          phone_number: phone_number,
          expiration_minutes: expiration_minutes
        }

        request[:attributes] = attributes if attributes != {}
        request[:user_id] = user_id unless user_id.nil?
        request[:session_token] = session_token unless session_token.nil?
        request[:session_jwt] = session_jwt unless session_jwt.nil?

        post_request("#{PATH}/send", request)
      end

      def login_or_create(
        phone_number:,
        expiration_minutes: nil,
        attributes: {},
        create_user_as_pending: false
      )
        request = {
          phone_number: phone_number,
          expiration_minutes: expiration_minutes,
          create_user_as_pending: create_user_as_pending
        }

        request[:attributes] = attributes if attributes != {}

        post_request("#{PATH}/login_or_create", request)
      end
    end

    class WhatsApp
      include Stytch::RequestHelper

      PATH = "#{Stytch::OTPs::PATH}/whatsapp"

      def initialize(connection)
        @connection = connection
      end

      def send(
        phone_number:,
        expiration_minutes: nil,
        attributes: {},
        user_id: nil,
        session_token: nil,
        session_jwt: nil,
      )
        request = {
          phone_number: phone_number,
          expiration_minutes: expiration_minutes
        }

        request[:attributes] = attributes if attributes != {}
        request[:user_id] = user_id unless user_id.nil?
        request[:session_token] = session_token unless session_token.nil?
        request[:session_jwt] = session_jwt unless session_jwt.nil?

        post_request("#{PATH}/send", request)
      end

      def login_or_create(
        phone_number:,
        expiration_minutes: nil,
        attributes: {},
        create_user_as_pending: false
      )
        request = {
          phone_number: phone_number,
          expiration_minutes: expiration_minutes,
          create_user_as_pending: create_user_as_pending
        }

        request[:attributes] = attributes if attributes != {}

        post_request("#{PATH}/login_or_create", request)
      end
    end

    class Email
      include Stytch::RequestHelper

      PATH = "#{Stytch::OTPs::PATH}/email"

      def initialize(connection)
        @connection = connection
      end

      def send(
        email:,
        expiration_minutes: nil,
        attributes: {},
        user_id: nil,
        session_token: nil,
        session_jwt: nil,
      )
        request = {
          email: email,
          expiration_minutes: expiration_minutes
        }

        request[:attributes] = attributes if attributes != {}
        request[:user_id] = user_id unless user_id.nil?
        request[:session_token] = session_token unless session_token.nil?
        request[:session_jwt] = session_jwt unless session_jwt.nil?

        post_request("#{PATH}/send", request)
      end

      def login_or_create(
        email:,
        expiration_minutes: nil,
        attributes: {},
        create_user_as_pending: false
      )
        request = {
          email: email,
          expiration_minutes: expiration_minutes,
          create_user_as_pending: create_user_as_pending
        }

        request[:attributes] = attributes if attributes != {}

        post_request("#{PATH}/login_or_create", request)
      end
    end
  end
end
