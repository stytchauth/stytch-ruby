# frozen_string_literal: true

# !!!
# WARNING: This file is autogenerated
# Only modify code within MANUAL() sections
# or your changes may be overwritten later!
# !!!

require_relative 'request_helper'

module Stytch
  class M2M
    include Stytch::RequestHelper
    attr_reader :clients

    def initialize(connection, project_id)
      @connection = connection

      @clients = Stytch::M2M::Clients.new(@connection)

      @project_id = project_id
      @cache_last_update = 0
      @jwks_loader = lambda do |options|
        @cached_keys = nil if options[:invalidate] && @cache_last_update < Time.now.to_i - 300
        @cached_keys ||= begin
          @cache_last_update = Time.now.to_i
          keys = []
          get_jwks(project_id: @project_id)['keys'].each do |r|
            keys << r
          end
          { keys: keys }
        end
      end
    end

    # MANUAL(M2M::get_jwks)(SERVICE_METHOD)
    # This is a helper so we can retrieve the JWKS for a project for decoding M2M access tokens
    def get_jwks(
      project_id:
    )
      query_params = {}
      request = request_with_query_params("/v1/sessions/jwks/#{project_id}", query_params)
      get_request(request)
    end
    # ENDMANUAL(M2M::get_jwks)

    # MANUAL(M2M::token)(SERVICE_METHOD)
    # +token+ retrieves an access token for the given M2M Client.
    # Access tokens are JWTs signed with the project's JWKs, and are valid for one hour after issuance.
    # M2M Access tokens contain a standard set of claims as well as any custom claims generated from templates.
    #
    # == Parameters:
    # client_id::
    #   The ID of the client.
    #   The type of this field is +String+.
    # client_secret::
    #   The secret of the client.
    #   The type of this field is +String+.
    # scopes::
    #   An array scopes requested. If omitted, all scopes assigned to the client will be returned.
    #   The type of this field is nilable list of +String+.
    #
    # == Returns:
    # An object with the following fields:
    # access_token::
    #   The access token granted to the client. Access tokens are JWTs signed with the project's JWKs.
    #   The type of this field is +String+.
    # expires_in::
    #   The lifetime in seconds of the access token.
    #   For example, the value 3600 denotes that the access token will expire in one hour from the time the response was generated.
    #   The type of this field is +Integer+.
    # token_type::
    #   The type of the returned access token. Today, this value will always be equal to "bearer"
    #   The type of this field is +String+.
    def token(client_id:, client_secret:, scopes: nil)
      request = {
        grant_type: 'client_credentials',
        client_id: client_id,
        client_secret: client_secret
      }
      request[:scope] = scopes.join(' ') unless scopes.nil?

      JSON.parse(post_request("/v1/public/#{@project_id}/oauth2/token", request), { symbolize_names: true })
    end
    # ENDMANUAL(M2M::token)

    # MANUAL(M2M::authenticate_token)(SERVICE_METHOD)
    # +authenticate_token+ validates a M2M JWT locally.
    #
    # == Parameters:
    # access_token::
    #   The access token granted to the client. Access tokens are JWTs signed with the project's JWKs.
    #   The type of this field is +String+.
    # required_scopes::
    #   A list of scopes the token must have to be valid.
    #   The type of this field is nilable list of +String+.
    # max_token_age::
    #   The maximum possible lifetime in seconds for the token to be valid.
    #   The type of this field is nilable +Integer+.
    # == Returns:
    # +nil+ if the token could not be validated, or an object with the following fields:
    # scopes::
    #   An array of scopes granted to the token holder.
    #   The type of this field is list of +String+.
    # client_id::
    #   The ID of the client that was issued the token
    #   The type of this field is +String+.
    # custom_claims::
    #   A map of custom claims present in the token.
    #   The type of this field is +object+.
    def authenticate_token(access_token:, required_scopes: nil, max_token_age: nil)
      # Intentionally allow this to re-raise if authentication fails
      decoded_jwt = authenticate_token_local(access_token)

      iat_time = Time.at(decoded_jwt['iat']).to_datetime

      # Token too old
      raise JWTExpiredError if !max_token_age.nil? && (iat_time + max_token_age < Time.now)

      resp = marshal_jwt_into_response(decoded_jwt)

      unless required_scopes.nil?
        for scope in required_scopes
          raise TokenMissingScopeError, scope unless resp['scopes'].include?(scope)
        end
      end

      resp
    end

    # Parse a M2M token and verify the signature locally (without calling /authenticate in the API)
    def authenticate_token_local(jwt)
      issuer = 'stytch.com/' + @project_id
      begin
        decoded_token = JWT.decode jwt, nil, true,
                                   { jwks: @jwks_loader, iss: issuer, verify_iss: true, aud: @project_id, verify_aud: true, algorithms: ['RS256'] }
        decoded_token[0]
      rescue JWT::InvalidIssuerError
        raise JWTInvalidIssuerError
      rescue JWT::InvalidAudError
        raise JWTInvalidAudienceError
      rescue JWT::ExpiredSignature
        raise JWTExpiredSignatureError
      rescue JWT::IncorrectAlgorithm
        raise JWTIncorrectAlgorithmError
      end
    end

    def marshal_jwt_into_response(jwt)
      # The custom claim set is all the claims in the payload except for the standard claims.
      # The cleanest way to collect those seems to be naming what we want
      # to omit and filtering the rest to collect the custom claims.
      reserved_claims = %w[aud exp iat iss jti nbf sub]
      custom_claims = jwt.reject { |key, _| reserved_claims.include?(key) }
      {
        'scopes' => jwt['scope'].split(' '),
        'client_id' => jwt['sub'],
        'custom_claims' => custom_claims
      }
    end
    # ENDMANUAL(M2M::authenticate_token)

    class Clients
      include Stytch::RequestHelper
      attr_reader :secrets

      def initialize(connection)
        @connection = connection

        @secrets = Stytch::M2M::Clients::Secrets.new(@connection)
      end

      # Gets information about an existing M2M Client.
      #
      # == Parameters:
      # client_id::
      #   The ID of the client.
      #   The type of this field is +String+.
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # m2m_client::
      #   The M2M Client affected by this operation.
      #   The type of this field is +M2MClient+ (+object+).
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      def get(
        client_id:
      )
        query_params = {}
        request = request_with_query_params("/v1/m2m/clients/#{client_id}", query_params)
        get_request(request)
      end

      # Search for M2M Clients within your Stytch Project. Submit an empty `query` in the request to return all M2M Clients.
      #
      # The following search filters are supported today:
      # - `client_id`: Pass in a list of client IDs to get many clients in a single request
      # - `client_name`: Search for clients by exact match on client name
      # - `scopes`: Search for clients assigned a specific scope
      #
      # == Parameters:
      # cursor::
      #   The `cursor` field allows you to paginate through your results. Each result array is limited to 1000 results. If your query returns more than 1000 results, you will need to paginate the responses using the `cursor`. If you receive a response that includes a non-null `next_cursor` in the `results_metadata` object, repeat the search call with the `next_cursor` value set to the `cursor` field to retrieve the next page of results. Continue to make search calls until the `next_cursor` in the response is null.
      #   The type of this field is nilable +String+.
      # limit::
      #   The number of search results to return per page. The default limit is 100. A maximum of 1000 results can be returned by a single search request. If the total size of your result set is greater than one page size, you must paginate the response. See the `cursor` field.
      #   The type of this field is nilable +Integer+.
      # query::
      #   The optional query object contains the operator, i.e. `AND` or `OR`, and the operands that will filter your results. Only an operator is required. If you include no operands, no filtering will be applied. If you include no query object, it will return all results with no filtering applied.
      #   The type of this field is nilable +M2MSearchQuery+ (+object+).
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # m2m_clients::
      #   An array of M2M Clients that match your search query.
      #   The type of this field is list of +M2MClient+ (+object+).
      # results_metadata::
      #   The search `results_metadata` object contains metadata relevant to your specific query like total and `next_cursor`.
      #   The type of this field is +ResultsMetadata+ (+object+).
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      def search(
        cursor: nil,
        limit: nil,
        query: nil
      )
        request = {}
        request[:cursor] = cursor unless cursor.nil?
        request[:limit] = limit unless limit.nil?
        request[:query] = query unless query.nil?

        post_request('/v1/m2m/clients/search', request)
      end

      # Updates an existing M2M Client. You can use this endpoint to activate or deactivate a M2M Client by changing its `status`. A deactivated M2M Client will not be allowed to perform future token exchange flows until it is reactivated.
      #
      # **Important:** Deactivating a M2M Client will not invalidate any existing JWTs issued to the client, only prevent it from receiving new ones.
      # To protect more-sensitive routes, pass a lower `max_token_age` value when[authenticating the token](https://stytch.com/docs/b2b/api/authenticate-m2m-token)[authenticating the token](https://stytch.com/docs/api/authenticate-m2m-token).
      #
      # == Parameters:
      # client_id::
      #   The ID of the client.
      #   The type of this field is +String+.
      # client_name::
      #   A human-readable name for the client.
      #   The type of this field is nilable +String+.
      # client_description::
      #   A human-readable description for the client.
      #   The type of this field is nilable +String+.
      # status::
      #   The status of the client - either `active` or `inactive`.
      #   The type of this field is nilable +UpdateRequestStatus+ (string enum).
      # scopes::
      #   An array of scopes assigned to the client.
      #   The type of this field is nilable list of +String+.
      # trusted_metadata::
      #   The `trusted_metadata` field contains an arbitrary JSON object of application-specific data. See the [Metadata](https://stytch.com/docs/api/metadata) reference for complete field behavior details.
      #   The type of this field is nilable +object+.
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # m2m_client::
      #   The M2M Client affected by this operation.
      #   The type of this field is +M2MClient+ (+object+).
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      def update(
        client_id:,
        client_name: nil,
        client_description: nil,
        status: nil,
        scopes: nil,
        trusted_metadata: nil
      )
        request = {}
        request[:client_name] = client_name unless client_name.nil?
        request[:client_description] = client_description unless client_description.nil?
        request[:status] = status unless status.nil?
        request[:scopes] = scopes unless scopes.nil?
        request[:trusted_metadata] = trusted_metadata unless trusted_metadata.nil?

        put_request("/v1/m2m/clients/#{client_id}", request)
      end

      # Deletes the M2M Client.
      #
      # **Important:** Deleting a M2M Client will not invalidate any existing JWTs issued to the client, only prevent it from receiving new ones.
      # To protect more-sensitive routes, pass a lower `max_token_age` value when[authenticating the token](https://stytch.com/docs/b2b/api/authenticate-m2m-token)[authenticating the token](https://stytch.com/docs/api/authenticate-m2m-token).
      #
      # == Parameters:
      # client_id::
      #   The ID of the client.
      #   The type of this field is +String+.
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # client_id::
      #   The ID of the client.
      #   The type of this field is +String+.
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      def delete(
        client_id:
      )
        delete_request("/v1/m2m/clients/#{client_id}")
      end

      # Creates a new M2M Client. On initial client creation, you may pass in a custom `client_id` or `client_secret` to import an existing M2M client. If you do not pass in a custom `client_id` or `client_secret`, one will be generated automatically. The `client_id` must be unique among all clients in your project.
      #
      # **Important:** This is the only time you will be able to view the generated `client_secret` in the API response. Stytch stores a hash of the `client_secret` and cannot recover the value if lost. Be sure to persist the `client_secret` in a secure location. If the `client_secret` is lost, you will need to trigger a secret rotation flow to receive another one.
      #
      # == Parameters:
      # scopes::
      #   An array of scopes assigned to the client.
      #   The type of this field is list of +String+.
      # client_id::
      #   If provided, the ID of the client to create. If not provided, Stytch will generate this value for you. The `client_id` must be unique within your project.
      #   The type of this field is nilable +String+.
      # client_secret::
      #   If provided, the stored secret of the client to create. If not provided, Stytch will generate this value for you. If provided, the `client_secret` must be at least 8 characters long and pass entropy requirements.
      #   The type of this field is nilable +String+.
      # client_name::
      #   A human-readable name for the client.
      #   The type of this field is nilable +String+.
      # client_description::
      #   A human-readable description for the client.
      #   The type of this field is nilable +String+.
      # trusted_metadata::
      #   The `trusted_metadata` field contains an arbitrary JSON object of application-specific data. See the [Metadata](https://stytch.com/docs/api/metadata) reference for complete field behavior details.
      #   The type of this field is nilable +object+.
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # m2m_client::
      #   The M2M Client created by this API call.
      #   The type of this field is +M2MClientWithClientSecret+ (+object+).
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      def create(
        scopes:,
        client_id: nil,
        client_secret: nil,
        client_name: nil,
        client_description: nil,
        trusted_metadata: nil
      )
        request = {
          scopes: scopes
        }
        request[:client_id] = client_id unless client_id.nil?
        request[:client_secret] = client_secret unless client_secret.nil?
        request[:client_name] = client_name unless client_name.nil?
        request[:client_description] = client_description unless client_description.nil?
        request[:trusted_metadata] = trusted_metadata unless trusted_metadata.nil?

        post_request('/v1/m2m/clients', request)
      end

      class Secrets
        include Stytch::RequestHelper

        def initialize(connection)
          @connection = connection
        end

        # Initiate the rotation of an M2M client secret. After this endpoint is called, both the client's `client_secret` and `next_client_secret` will be valid. To complete the secret rotation flow, update all usages of `client_secret` to `next_client_secret` and call the [Rotate Secret Endpoint](https://stytch.com/docs/b2b/api/m2m-rotate-secret)[Rotate Secret Endpoint](https://stytch.com/docs/api/m2m-rotate-secret) to complete the flow.
        # Secret rotation can be cancelled using the [Rotate Cancel Endpoint](https://stytch.com/docs/b2b/api/m2m-rotate-secret-cancel)[Rotate Cancel Endpoint](https://stytch.com/docs/api/m2m-rotate-secret-cancel).
        #
        # **Important:** This is the only time you will be able to view the generated `next_client_secret` in the API response. Stytch stores a hash of the `next_client_secret` and cannot recover the value if lost. Be sure to persist the `next_client_secret` in a secure location. If the `next_client_secret` is lost, you will need to trigger a secret rotation flow to receive another one.
        #
        # == Parameters:
        # client_id::
        #   The ID of the client.
        #   The type of this field is +String+.
        #
        # == Returns:
        # An object with the following fields:
        # request_id::
        #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
        #   The type of this field is +String+.
        # m2m_client::
        #   The M2M Client affected by this operation.
        #   The type of this field is +M2MClientWithNextClientSecret+ (+object+).
        # status_code::
        #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
        #   The type of this field is +Integer+.
        def rotate_start(
          client_id:
        )
          request = {}

          post_request("/v1/m2m/clients/#{client_id}/secrets/rotate/start", request)
        end

        # Cancel the rotation of an M2M client secret started with the [Start Secret Rotation Endpoint](https://stytch.com/docs/b2b/api/m2m-rotate-secret-start) [Start Secret Rotation Endpoint](https://stytch.com/docs/api/m2m-rotate-secret-start).
        # After this endpoint is called, the client's `next_client_secret` is discarded and only the original `client_secret` will be valid.
        #
        # == Parameters:
        # client_id::
        #   The ID of the client.
        #   The type of this field is +String+.
        #
        # == Returns:
        # An object with the following fields:
        # request_id::
        #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
        #   The type of this field is +String+.
        # m2m_client::
        #   The M2M Client affected by this operation.
        #   The type of this field is +M2MClient+ (+object+).
        # status_code::
        #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
        #   The type of this field is +Integer+.
        def rotate_cancel(
          client_id:
        )
          request = {}

          post_request("/v1/m2m/clients/#{client_id}/secrets/rotate/cancel", request)
        end

        # Complete the rotation of an M2M client secret started with the [Start Secret Rotation Endpoint](https://stytch.com/docs/b2b/api/m2m-rotate-secret-start) [Start Secret Rotation Endpoint](https://stytch.com/docs/api/m2m-rotate-secret-start).
        # After this endpoint is called, the client's `next_client_secret` becomes its `client_secret` and the previous `client_secret` will no longer be valid.
        #
        # == Parameters:
        # client_id::
        #   The ID of the client.
        #   The type of this field is +String+.
        #
        # == Returns:
        # An object with the following fields:
        # request_id::
        #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
        #   The type of this field is +String+.
        # m2m_client::
        #   The M2M Client affected by this operation.
        #   The type of this field is +M2MClient+ (+object+).
        # status_code::
        #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
        #   The type of this field is +Integer+.
        def rotate(
          client_id:
        )
          request = {}

          post_request("/v1/m2m/clients/#{client_id}/secrets/rotate", request)
        end
      end
    end
  end
end