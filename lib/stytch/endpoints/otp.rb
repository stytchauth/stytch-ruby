module Stytch
  module Endpoints
    module OTP
      PATH = "/v1/otps".freeze

      def otps_sms_send(
        phone_number:,
        expiration_minutes: nil,
        attributes: {}
      )
        request = {
          phone_number: phone_number,
          expiration_minutes: expiration_minutes,
        }

        request[:attributes] = attributes if attributes != {}

        post("#{PATH}/sms/send", request)
      end

      def otps_sms_login_or_create(
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

        post("#{PATH}/sms/login_or_create", request)
      end

      def otps_authenticate(
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
