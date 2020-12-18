module Stytch
  module Endpoints
    module User
      PATH = "/v1/users".freeze

      def get_user(user_id:)
        get("#{PATH}/#{user_id}")
      end

      def get_invited_users()
        get("#{PATH}/invites")
      end

      def create_user(
          email:,
          name: {},
          attributes: {}
      )
        request = {
          email: email,
        }

        request[:name] = name if name != {}
        request[:attributes] = attributes if attributes != {}

        post(PATH, request)
      end

      def update_user(
        user_id:,
        name: {},
        emails: [],
        attributes: {}
      )
        request = {
            emails: format_emails(emails),
        }

        request[:name] = name if name != {}
        request[:attributes] = attributes if attributes != {}

        put("#{PATH}/#{user_id}", request)
      end

      def delete_user(user_id:)
        delete("#{PATH}/#{user_id}")
      end

      private

      def format_emails(emails)
        e = []
        emails.each { |email| e << { email: email} }
        e
      end
    end
  end
end
