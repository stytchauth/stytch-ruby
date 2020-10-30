module Stytch
  module Endpoints
    module User
      CREATE_USER_PATH = "/v1/users".freeze

      def create_user(
          email:,
          first_name: "",
          middle_name: "",
          last_name: "",
          ip_address: "",
          user_agent: ""
      )
        post_with_auth(
          CREATE_USER_PATH,
          {
            email: email,
            name: {
              first_name: first_name,
              middle_name: middle_name,
              last_name: last_name,
            },
            attributes: {
              ip_address: ip_address,
              user_agent: user_agent,
            },
          }
        )
      end
    end
  end
end