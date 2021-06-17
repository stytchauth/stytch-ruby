module Stytch
  module Endpoints
    module Magic
      PATH = "/v1/magic_links".freeze

      def magic_links_email_send(
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

        post("#{PATH}/email/send", request)
      end

      def magic_links_email_login_or_create(
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

        post("#{PATH}/email/login_or_create", request)
      end

      def magic_links_email_invite(
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

        post("#{PATH}/email/invite", request)
      end

      def magic_links_email_revoke_invite(
        email:
      )
        request = {
          email: email,
        }

        post("#{PATH}/email/revoke_invite", request)
      end

      def magic_links_authenticate(
        token:,
        attributes: {},
        options: {}
      )
        request = {
            token: token,
        }

        request[:attributes] = attributes if attributes != {}
        request[:options] = options if options != {}

        post("#{PATH}/authenticate", request)
      end
    end
  end
end
