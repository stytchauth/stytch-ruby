module Stytch
  module Endpoints
    module User
      PATH = "/v1/users".freeze

      def get_user(user_id:)
        get("#{PATH}/#{user_id}")
      end

      def get_pending_users(
          limit: nil,
          starting_after_id: nil
      )
        query_params = {
            limit: limit,
            starting_after_id: starting_after_id,
        }

        request = request_with_query_params("#{PATH}/pending", query_params)

        get(request)
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

      def delete_user_email(
        user_id:,
        email:
      )
        delete("#{PATH}/#{user_id}/emails/#{email}")
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
