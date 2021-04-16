module Stytch
  module Endpoints
    module Magic
      PATH = "/v1/magic_links".freeze

      def send_magic(
          method_id:,
          user_id:,
          magic_link_url:,
          expiration_minutes: nil,
          attributes: {}
      )
        request = {
            method_id: method_id,
            user_id: user_id,
            magic_link_url: magic_link_url,
        }

        request[:expiration_minutes] = expiration_minutes if expiration_minutes != nil
        request[:attributes] = attributes if attributes != {}

        post("#{PATH}/send", request)
      end

      def send_magic_by_email(
          email:,
          magic_link_url:,
          expiration_minutes: nil,
          attributes: {}
      )
        request = {
            email: email,
            magic_link_url: magic_link_url,
        }

        request[:expiration_minutes] = expiration_minutes if expiration_minutes != nil
        request[:attributes] = attributes if attributes != {}

        post("#{PATH}/send_by_email", request)
      end

      def login_or_create_user(
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

        post("#{PATH}/login_or_create", request)
      end

      def invite_by_email(
        email:,
        magic_link_url:,
        expiration_minutes: nil,
        attributes: {},
        name: {}
      )

        request = {
          email: email,
          magic_link_url: magic_link_url,
        }

        request[:expiration_minutes] = expiration_minutes if expiration_minutes != nil
        request[:attributes] = attributes if attributes != {}
        request[:name] = name if name != {}

        post("#{PATH}/invite_by_email", request)
      end

      def revoke_invite_by_email(
        email:
      )

        request = {
          email: email,
        }

        post("#{PATH}/revoke_invite", request)
      end

      def authenticate_magic(
          token:,
          attributes: {},
          options: {}
      )
        request = {}

        request[:attributes] = attributes if attributes != {}
        request[:options] = options if options != {}

        post("#{PATH}/#{token}/authenticate", request)
      end
    end
  end
end
