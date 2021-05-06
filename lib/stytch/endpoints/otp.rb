module Stytch
  module Endpoints
    module OTP
      PATH = "/v1/otp".freeze

      def send_otp_by_sms(
        phone_number:,
        expiration_minutes: nil,
        attributes: {}
      )
        request = {
          phone_number: phone_number,
          expiration_minutes: expiration_minutes,
        }

        request[:attributes] = attributes if attributes != {}

        post("#{PATH}/send_by_sms", request)
      end

      def login_or_create_user_by_sms(
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

        post("#{PATH}/login_or_create", request)
      end

      def authenticate_otp(
        method_id:,
        code:,
        attributes: {},
        options: {}
      )
        request = {
          method_id: method_id,
          code: code,
        }

        request[:attributes] = attributes if attributes != {}
        request[:options] = options if options != {}

        post("#{PATH}/authenticate", request)
      end
    end
  end
end
