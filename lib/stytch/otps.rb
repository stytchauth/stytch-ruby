# frozen_string_literal: true

require_relative 'request_helper'

module Stytch
  class OTPs
    include Stytch::RequestHelper

    attr_reader :sms, :whatsapp

    PATH = '/v1/otps'

    def initialize(connection)
      @connection = connection

      @sms = Stytch::OTPs::SMS.new(@connection)
      @whatsapp = Stytch::OTPs::WhatsApp.new(@connection)
    end

    def authenticate(
      method_id:,
      code:,
      attributes: {},
      options: {},
      session_token: nil,
      session_duration_minutes: nil
    )
      request = {
        method_id: method_id,
        code: code
      }

      request[:attributes] = attributes if attributes != {}
      request[:options] = options if options != {}
      request[:session_token] = session_token unless session_token.nil?
      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?

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
        attributes: {}
      )
        request = {
          phone_number: phone_number,
          expiration_minutes: expiration_minutes
        }

        request[:attributes] = attributes if attributes != {}

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
        attributes: {}
      )
        request = {
          phone_number: phone_number,
          expiration_minutes: expiration_minutes
        }

        request[:attributes] = attributes if attributes != {}

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
  end
end
