module Stytch
  module Endpoints
    module Magic
      PATH = "/v1/magic_links".freeze

      def send_magic(
          method_id:,
          user_id:,
          magic_link_url:,
          expiration_minutes:,
          template_id: nil,
          attributes: {}
      )
        request = {
            method_id: method_id,
            user_id: user_id,
            magic_link_url: magic_link_url,
            expiration_minutes: expiration_minutes,
            template_id: template_id,
            attributes: attributes
        }

        post("#{PATH}/send", request)
      end

      def send_magic_by_email(
          email:,
          magic_link_url:,
          expiration_minutes:,
          template_id: nil,
          attributes: {}
      )
        request = {
            email: email,
            magic_link_url: magic_link_url,
            expiration_minutes: expiration_minutes,
            template_id: template_id,
            attributes: attributes
        }

        post("#{PATH}/send_by_email", request)
      end

      def authenticate_magic(
          token:,
          attributes: {},
          options:{}
      )
        request = {
            attributes: attributes,
            options: options
        }

        post("#{PATH}/#{token}/authenticate", request)
      end
    end
  end
end