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
        phone_number: nil,
        name: {},
        attributes: {}
      )
        request = {
          email: email,
          phone_number: phone_number
        }

        request[:name] = name if name != {}
        request[:attributes] = attributes if attributes != {}

        post(PATH, request)
      end

      def update_user(
        user_id:,
        name: {},
        emails: [],
        phone_numbers: [],
        attributes: {}
      )
        request = {
          emails: format_emails(emails),
          phone_numbers: format_phone_numbers(phone_numbers),
        }

        request[:name] = name if name != {}
        request[:attributes] = attributes if attributes != {}

        put("#{PATH}/#{user_id}", request)
      end

      def delete_user(user_id:)
        delete("#{PATH}/#{user_id}")
      end

      def delete_user_email(
        email_id:
      )
        delete("#{PATH}/emails/#{email_id}")
      end

      def delete_user_phone_number(
        phone_id:
      )
        delete("#{PATH}/phone_numbers/#{phone_id}")
      end

      private

      def format_emails(emails)
        e = []
        emails.each { |email| e << { email: email} }
        e
      end

      def format_phone_numbers(phone_numbers)
        p = []
        phone_numbers.each { |phone_number| p << { phone_number: phone_number} }
        p
      end
    end
  end
end
