module Stytch
  module Endpoints
    module Email
      PATH = "/v1/emails".freeze

      def delete_email(user_id:, email_id:)
        delete("#{PATH}/#{email_id}/users/#{user_id}")
      end
    end
  end
end
