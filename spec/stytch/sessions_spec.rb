# frozen_string_literal: true


require 'faraday'
require 'faraday_middleware'

require_relative '../../lib/stytch/client'
require_relative '../../lib/stytch/middleware'
require_relative '../../lib/stytch/version'

require 'test/unit'

class TestSessions < Test::Unit::TestCase
    def test_correctly_decode_jwt
        project_id = "project-test-00000000-0000-0000-0000-000000000000"
        client = Stytch::Client.new(
            env: :test,
            project_id: project_id,
            secret: "" # the methods we're calling don't require project authentication
        )
        kid = "jwk-test-00000000-0000-0000-0000-000000000000"
        headers = { kid: kid }

        now = Time.now.to_datetime.iso8601
        claims = {
            "https://stytch.com/session" => {
                "started_at" => now,
                "last_accessed_at" => now,
                "attributes" => {"user_agent" => "", "ip_address" => ""},
                "authentication_factors" => [
                        {
                            "delivery_method" => "email",
                            "email_factor" => {
                                "email_address" => "sandbox@stytch.com",
                                "email_id" => "email-live-cca9d7d0-11b6-4167-9385-d7e0c9a77418",
                        },
                        "last_authenticated_at" => now,
                        "type" => "magic_link",
                    },
                ],
                "id" => "session-live-e26a0ccb-0dc0-4edb-a4bb-e70210f43555",
            },
            "sub" => "user-live-fde03dd1-fff7-4b3c-9b31-ead3fbc224de",
            "iat" => now.to_time.to_i,
            "nbf" => now.to_time.to_i,
            "exp" => now.to_time.to_i + 3600,  # one hour
            "iss" => "stytch.com/" + project_id,
            "aud" => [project_id],
        }
        jwk = JWT::JWK.new(OpenSSL::PKey::RSA.new(2048), kid)
        token = JWT.encode(claims, jwk.keypair, 'RS256', headers)

        # patch the jwks_loader method so that it uses the JWK we just created
        # instead of calling the API directly
        patch_jwks_loader = ->(options) do
            {"keys" => [jwk.export]}
        end
        client.sessions.instance_variable_set(:@jwks_loader, patch_jwks_loader)
        
        resp = client.sessions.authenticate_jwt_local(token)
        assert_equal(resp, claims)
    end
end
