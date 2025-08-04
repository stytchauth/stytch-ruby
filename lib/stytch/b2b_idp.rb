# frozen_string_literal: true

require 'jwt'
require 'json/jwt'
require_relative 'errors'
require_relative 'request_helper'
require_relative 'rbac_local'

module StytchB2B
  class IDP
    include Stytch::RequestHelper

    def initialize(connection, project_id, policy_cache)
      @connection = connection
      @project_id = project_id
      @policy_cache = policy_cache
      @non_custom_claim_keys = [
        'aud',
        'exp',
        'iat',
        'iss',
        'jti',
        'nbf',
        'sub',
        'active',
        'client_id',
        'request_id',
        'scope',
        'status_code',
        'token_type',
        'https://stytch.com/organization'
      ]
    end

    # Introspects a token JWT from an authorization code response.
    # Access tokens are JWTs signed with the project's JWKs. Refresh tokens are opaque tokens.
    # Access tokens contain a standard set of claims as well as any custom claims generated from templates.
    #
    # == Parameters:
    # token::
    #   The access token (or refresh token) to introspect.
    #   The type of this field is +String+.
    # client_id::
    #   The ID of the client.
    #   The type of this field is +String+.
    # client_secret::
    #   The secret of the client.
    #   The type of this field is nilable +String+.
    # token_type_hint::
    #   A hint on what the token contains. Valid fields are 'access_token' and 'refresh_token'.
    #   The type of this field is +String+.
    # authorization_check::
    #   Optional authorization check object.
    #   The type of this field is nilable +Hash+.
    #
    # == Returns:
    # An object with the following fields:
    # subject::
    #   The subject of the token.
    #   The type of this field is +String+.
    # scope::
    #   The scope of the token.
    #   The type of this field is +String+.
    # audience::
    #   The audience of the token.
    #   The type of this field is +String+.
    # expires_at::
    #   The expiration time of the token.
    #   The type of this field is +Integer+.
    # issued_at::
    #   The issued at time of the token.
    #   The type of this field is +Integer+.
    # issuer::
    #   The issuer of the token.
    #   The type of this field is +String+.
    # not_before::
    #   The not before time of the token.
    #   The type of this field is +Integer+.
    # token_type::
    #   The type of the token.
    #   The type of this field is +String+.
    # custom_claims::
    #   Custom claims in the token.
    #   The type of this field is +Hash+.
    # organization_claim::
    #   The organization claim in the token.
    #   The type of this field is +Hash+.
    def introspect_token_network(
      token:,
      client_id:,
      client_secret: nil,
      token_type_hint: 'access_token',
      authorization_check: nil
    )
      headers = {}
      data = {
        'token' => token,
        'client_id' => client_id,
        'token_type_hint' => token_type_hint
      }
      data['client_secret'] = client_secret unless client_secret.nil?

      url = @connection.url_prefix + "/v1/public/#{@project_id}/oauth2/introspect"
      jwt_response = post_request(url, data, headers)

      return nil unless jwt_response['active']

      custom_claims = jwt_response.reject { |k, _| @non_custom_claim_keys.include?(k) }
      organization_claim = jwt_response['https://stytch.com/organization']
      organization_id = organization_claim['organization_id']
      scope = jwt_response['scope']

      if authorization_check
        @policy_cache.perform_authorization_check(
          subject_roles: scope.split,
          authorization_check: authorization_check,
          subject_org_id: organization_id
        )
      end

      {
        'subject' => jwt_response['sub'],
        'scope' => jwt_response['scope'],
        'audience' => jwt_response['aud'],
        'expires_at' => jwt_response['exp'],
        'issued_at' => jwt_response['iat'],
        'issuer' => jwt_response['iss'],
        'not_before' => jwt_response['nbf'],
        'token_type' => jwt_response['token_type'],
        'custom_claims' => custom_claims,
        'organization_claim' => organization_claim
      }
    end

    # Introspects a token JWT from an authorization code response.
    # Access tokens are JWTs signed with the project's JWKs. Refresh tokens are opaque tokens.
    # Access tokens contain a standard set of claims as well as any custom claims generated from templates.
    #
    # == Parameters:
    # access_token::
    #   The access token (or refresh token) to introspect.
    #   The type of this field is +String+.
    # authorization_check::
    #   Optional authorization check object.
    #   The type of this field is nilable +Hash+.
    #
    # == Returns:
    # An object with the following fields:
    # subject::
    #   The subject of the token.
    #   The type of this field is +String+.
    # scope::
    #   The scope of the token.
    #   The type of this field is +String+.
    # audience::
    #   The audience of the token.
    #   The type of this field is +String+.
    # expires_at::
    #   The expiration time of the token.
    #   The type of this field is +Integer+.
    # issued_at::
    #   The issued at time of the token.
    #   The type of this field is +Integer+.
    # issuer::
    #   The issuer of the token.
    #   The type of this field is +String+.
    # not_before::
    #   The not before time of the token.
    #   The type of this field is +Integer+.
    # token_type::
    #   The type of the token.
    #   The type of this field is +String+.
    # custom_claims::
    #   Custom claims in the token.
    #   The type of this field is +Hash+.
    # organization_claim::
    #   The organization claim in the token.
    #   The type of this field is +Hash+.
    def introspect_access_token_local(
      access_token:,
      authorization_check: nil
    )
      scope_claim = 'scope'
      organization_claim = 'https://stytch.com/organization'

      # Create a JWKS loader similar to other classes in the codebase
      @cache_last_update = 0
      jwks_loader = lambda do |options|
        @cached_keys = nil if options[:invalidate] && @cache_last_update < Time.now.to_i - 300
        if @cached_keys.nil?
          @cached_keys = get_jwks(project_id: @project_id)
          @cache_last_update = Time.now.to_i
        end
        @cached_keys
      end

      begin
        decoded_jwt = JWT.decode(
          access_token,
          nil,
          true,
          {
            algorithms: ['RS256'],
            jwks: jwks_loader,
            iss: ["stytch.com/#{@project_id}", @connection.url_prefix],
            aud: @project_id
          }
        )[0]

        generic_claims = decoded_jwt
        custom_claims = generic_claims.reject { |k, _| @non_custom_claim_keys.include?(k) }
        organization_claim_data = generic_claims[organization_claim]
        organization_id = organization_claim_data['organization_id']
        scope = generic_claims[scope_claim]

        if authorization_check
          @policy_cache.perform_authorization_check(
            subject_roles: scope.split,
            authorization_check: authorization_check,
            subject_org_id: organization_id
          )
        end

        {
          'subject' => generic_claims['sub'],
          'scope' => generic_claims[scope_claim],
          'audience' => generic_claims['aud'],
          'expires_at' => generic_claims['exp'],
          'issued_at' => generic_claims['iat'],
          'issuer' => generic_claims['iss'],
          'not_before' => generic_claims['nbf'],
          'token_type' => 'access_token',
          'custom_claims' => custom_claims,
          'organization_claim' => organization_claim_data
        }
      rescue JWT::InvalidIssuerError
        raise Stytch::JWTInvalidIssuerError
      rescue JWT::InvalidAudError
        raise Stytch::JWTInvalidAudienceError
      rescue JWT::ExpiredSignature
        raise Stytch::JWTExpiredSignatureError
      rescue JWT::IncorrectAlgorithm
        raise Stytch::JWTIncorrectAlgorithmError
      rescue JWT::DecodeError
        nil
      end
    end

    # Gets the JWKS for the project.
    #
    # == Parameters:
    # project_id::
    #   The ID of the project.
    #   The type of this field is +String+.
    #
    # == Returns:
    # The JWKS for the project.
    #   The type of this field is +Hash+.
    def get_jwks(project_id:)
      headers = {}
      query_params = {}
      request = request_with_query_params("/v1/b2b/sessions/jwks/#{project_id}", query_params)
      get_request(request, headers)
    end
  end
end
