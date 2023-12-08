module Stytch
  module MethodOptions
    class Authorization
      # A secret token for a given Stytch Session.
      attr_accessor :session_token
      # The JSON Web Token (JWT) for a given Stytch Session.
      attr_accessor :session_jwt

      def initialize(session_token: nil, session_jwt: nil)
        @session_token = session_token
        @session_jwt = session_jwt
      end

      def to_headers
        headers = {}
        headers['X-Stytch-Member-Session'] = session_token if session_token
        headers['X-Stytch-Member-SessionJWT'] = session_jwt if session_jwt
        headers
      end
    end
  end
end
