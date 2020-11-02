module Stytch
  module Endpoints
    module Email
      PATH = "/v1/emails".freeze

      def send_email_verification(
          user_id:,
          email_id:,
          magic_link_url:,
          expiration_minutes:
      )
        request = {
            user_id: user_id,
            magic_link_url: magic_link_url,
            expiration_minutes: expiration_minutes
        }

        post("#{PATH}/#{email_id}/send_verification", request)
      end

      def verify_email(token:)
        post("#{PATH}/#{token}/verify")
      end
    end
  end
end