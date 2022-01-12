# frozen_string_literal: true

require_relative 'request_helper'

module Stytch
  class TOTPs
    include Stytch::RequestHelper

    PATH = '/v1/totps'

    def initialize(connection)
      @connection = connection
    end

    def create(
      user_id:,
      expiration_minutes: nil
    )
      request = {
        user_id: user_id,
      }

      request[:expiration_minutes] = expiration_minutes unless expiration_minutes.nil?

      post_request("#{PATH}", request)
    end

    def authenticate(
      user_id:,
      totp_code:,
      session_token: nil,
      session_duration_minutes: nil
    )
      request = {
        user_id: user_id,
        totp_code: totp_code
      }

      request[:session_token] = session_token unless session_token.nil?
            request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?

      post_request("#{PATH}/authenticate", request)
    end

    def recovery_codes(
      user_id:
    )
      request = {
        user_id: user_id,
      }

      post_request("#{PATH}/recovery_codes", request)
    end

    def recover(
      user_id:,
      recovery_code:
    )
      request = {
        user_id: user_id,
        recovery_code: recovery_code,
      }

      post_request("#{PATH}/recover", request)
    end
  end
end
