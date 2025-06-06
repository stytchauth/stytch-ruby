# frozen_string_literal: true

# !!!
# WARNING: This file is autogenerated
# Only modify code within MANUAL() sections
# or your changes may be overwritten later!
# !!!

require_relative 'request_helper'

module StytchB2B
  class SCIM
    include Stytch::RequestHelper
    attr_reader :connection

    def initialize(connection)
      @connection = connection

      @connection = StytchB2B::SCIM::Connection.new(@connection)
    end

    class Connection
      class UpdateRequestOptions
        # Optional authorization object.
        # Pass in an active Stytch Member session token or session JWT and the request
        # will be run using that member's permissions.
        attr_accessor :authorization

        def initialize(
          authorization: nil
        )
          @authorization = authorization
        end

        def to_headers
          headers = {}
          headers.merge!(@authorization.to_headers) if authorization
          headers
        end
      end

      class DeleteRequestOptions
        # Optional authorization object.
        # Pass in an active Stytch Member session token or session JWT and the request
        # will be run using that member's permissions.
        attr_accessor :authorization

        def initialize(
          authorization: nil
        )
          @authorization = authorization
        end

        def to_headers
          headers = {}
          headers.merge!(@authorization.to_headers) if authorization
          headers
        end
      end

      class RotateStartRequestOptions
        # Optional authorization object.
        # Pass in an active Stytch Member session token or session JWT and the request
        # will be run using that member's permissions.
        attr_accessor :authorization

        def initialize(
          authorization: nil
        )
          @authorization = authorization
        end

        def to_headers
          headers = {}
          headers.merge!(@authorization.to_headers) if authorization
          headers
        end
      end

      class RotateCompleteRequestOptions
        # Optional authorization object.
        # Pass in an active Stytch Member session token or session JWT and the request
        # will be run using that member's permissions.
        attr_accessor :authorization

        def initialize(
          authorization: nil
        )
          @authorization = authorization
        end

        def to_headers
          headers = {}
          headers.merge!(@authorization.to_headers) if authorization
          headers
        end
      end

      class RotateCancelRequestOptions
        # Optional authorization object.
        # Pass in an active Stytch Member session token or session JWT and the request
        # will be run using that member's permissions.
        attr_accessor :authorization

        def initialize(
          authorization: nil
        )
          @authorization = authorization
        end

        def to_headers
          headers = {}
          headers.merge!(@authorization.to_headers) if authorization
          headers
        end
      end

      class GetGroupsRequestOptions
        # Optional authorization object.
        # Pass in an active Stytch Member session token or session JWT and the request
        # will be run using that member's permissions.
        attr_accessor :authorization

        def initialize(
          authorization: nil
        )
          @authorization = authorization
        end

        def to_headers
          headers = {}
          headers.merge!(@authorization.to_headers) if authorization
          headers
        end
      end

      class CreateRequestOptions
        # Optional authorization object.
        # Pass in an active Stytch Member session token or session JWT and the request
        # will be run using that member's permissions.
        attr_accessor :authorization

        def initialize(
          authorization: nil
        )
          @authorization = authorization
        end

        def to_headers
          headers = {}
          headers.merge!(@authorization.to_headers) if authorization
          headers
        end
      end

      class GetRequestOptions
        # Optional authorization object.
        # Pass in an active Stytch Member session token or session JWT and the request
        # will be run using that member's permissions.
        attr_accessor :authorization

        def initialize(
          authorization: nil
        )
          @authorization = authorization
        end

        def to_headers
          headers = {}
          headers.merge!(@authorization.to_headers) if authorization
          headers
        end
      end

      include Stytch::RequestHelper

      def initialize(connection)
        @connection = connection
      end

      # Update a SCIM Connection.
      #
      # == Parameters:
      # organization_id::
      #   Globally unique UUID that identifies a specific Organization. The `organization_id` is critical to perform operations on an Organization, so be sure to preserve this value. You may also use the organization_slug here as a convenience.
      #   The type of this field is +String+.
      # connection_id::
      #   The ID of the SCIM connection.
      #   The type of this field is +String+.
      # display_name::
      #   A human-readable display name for the connection.
      #   The type of this field is nilable +String+.
      # identity_provider::
      #   (no documentation yet)
      #   The type of this field is nilable +UpdateRequestIdentityProvider+ (string enum).
      # scim_group_implicit_role_assignments::
      #   An array of SCIM group implicit role assignments. Each object in the array must contain a `group_id` and a `role_id`.
      #   The type of this field is nilable list of +SCIMGroupImplicitRoleAssignments+.
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      # connection::
      #   The `SAML Connection` object affected by this API call. See the [SAML Connection Object](https://stytch.com/docs/b2b/api/saml-connection-object) for complete response field details.
      #   The type of this field is nilable +SCIMConnection+ (+object+).
      #
      # == Method Options:
      # This method supports an optional +StytchB2B::SCIM::Connection::UpdateRequestOptions+ object which will modify the headers sent in the HTTP request.
      def update(
        organization_id:,
        connection_id:,
        display_name: nil,
        identity_provider: nil,
        scim_group_implicit_role_assignments: nil,
        method_options: nil
      )
        headers = {}
        headers = headers.merge(method_options.to_headers) unless method_options.nil?
        request = {}
        request[:display_name] = display_name unless display_name.nil?
        request[:identity_provider] = identity_provider unless identity_provider.nil?
        request[:scim_group_implicit_role_assignments] = scim_group_implicit_role_assignments unless scim_group_implicit_role_assignments.nil?

        put_request("/v1/b2b/scim/#{organization_id}/connection/#{connection_id}", request, headers)
      end

      # Deletes a SCIM Connection.
      #
      # == Parameters:
      # organization_id::
      #   Globally unique UUID that identifies a specific Organization. The `organization_id` is critical to perform operations on an Organization, so be sure to preserve this value. You may also use the organization_slug here as a convenience.
      #   The type of this field is +String+.
      # connection_id::
      #   The ID of the SCIM connection.
      #   The type of this field is +String+.
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # connection_id::
      #   The `connection_id` that was deleted as part of the delete request.
      #   The type of this field is +String+.
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      #
      # == Method Options:
      # This method supports an optional +StytchB2B::SCIM::Connection::DeleteRequestOptions+ object which will modify the headers sent in the HTTP request.
      def delete(
        organization_id:,
        connection_id:,
        method_options: nil
      )
        headers = {}
        headers = headers.merge(method_options.to_headers) unless method_options.nil?
        delete_request("/v1/b2b/scim/#{organization_id}/connection/#{connection_id}", headers)
      end

      # Start a SCIM token rotation.
      #
      # == Parameters:
      # organization_id::
      #   Globally unique UUID that identifies a specific Organization. The `organization_id` is critical to perform operations on an Organization, so be sure to preserve this value. You may also use the organization_slug here as a convenience.
      #   The type of this field is +String+.
      # connection_id::
      #   The ID of the SCIM connection.
      #   The type of this field is +String+.
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      # connection::
      #   The `SCIM Connection` object affected by this API call. See the [SCIM Connection Object](https://stytch.com/docs/b2b/api/scim-connection-object) for complete response field details.
      #   The type of this field is nilable +SCIMConnectionWithNextToken+ (+object+).
      #
      # == Method Options:
      # This method supports an optional +StytchB2B::SCIM::Connection::RotateStartRequestOptions+ object which will modify the headers sent in the HTTP request.
      def rotate_start(
        organization_id:,
        connection_id:,
        method_options: nil
      )
        headers = {}
        headers = headers.merge(method_options.to_headers) unless method_options.nil?
        request = {}

        post_request("/v1/b2b/scim/#{organization_id}/connection/#{connection_id}/rotate/start", request, headers)
      end

      # Completes a SCIM token rotation. This will complete the current token rotation process and update the active token to be the new token supplied in the [start SCIM token rotation](https://stytch.com/docs/b2b/api/scim-rotate-token-start) response.
      #
      # == Parameters:
      # organization_id::
      #   Globally unique UUID that identifies a specific Organization. The `organization_id` is critical to perform operations on an Organization, so be sure to preserve this value. You may also use the organization_slug here as a convenience.
      #   The type of this field is +String+.
      # connection_id::
      #   The ID of the SCIM connection.
      #   The type of this field is +String+.
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      # connection::
      #   The `SCIM Connection` object affected by this API call. See the [SCIM Connection Object](https://stytch.com/docs/b2b/api/scim-connection-object) for complete response field details.
      #   The type of this field is nilable +SCIMConnection+ (+object+).
      #
      # == Method Options:
      # This method supports an optional +StytchB2B::SCIM::Connection::RotateCompleteRequestOptions+ object which will modify the headers sent in the HTTP request.
      def rotate_complete(
        organization_id:,
        connection_id:,
        method_options: nil
      )
        headers = {}
        headers = headers.merge(method_options.to_headers) unless method_options.nil?
        request = {}

        post_request("/v1/b2b/scim/#{organization_id}/connection/#{connection_id}/rotate/complete", request, headers)
      end

      # Cancel a SCIM token rotation. This will cancel the current token rotation process, keeping the original token active.
      #
      # == Parameters:
      # organization_id::
      #   Globally unique UUID that identifies a specific Organization. The `organization_id` is critical to perform operations on an Organization, so be sure to preserve this value. You may also use the organization_slug here as a convenience.
      #   The type of this field is +String+.
      # connection_id::
      #   The ID of the SCIM connection.
      #   The type of this field is +String+.
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      # connection::
      #   The `SCIM Connection` object affected by this API call. See the [SCIM Connection Object](https://stytch.com/docs/b2b/api/scim-connection-object) for complete response field details.
      #   The type of this field is nilable +SCIMConnection+ (+object+).
      #
      # == Method Options:
      # This method supports an optional +StytchB2B::SCIM::Connection::RotateCancelRequestOptions+ object which will modify the headers sent in the HTTP request.
      def rotate_cancel(
        organization_id:,
        connection_id:,
        method_options: nil
      )
        headers = {}
        headers = headers.merge(method_options.to_headers) unless method_options.nil?
        request = {}

        post_request("/v1/b2b/scim/#{organization_id}/connection/#{connection_id}/rotate/cancel", request, headers)
      end

      # Gets a paginated list of all SCIM Groups associated with a given Connection.
      #
      # == Parameters:
      # organization_id::
      #   Globally unique UUID that identifies a specific Organization. The `organization_id` is critical to perform operations on an Organization, so be sure to preserve this value. You may also use the organization_slug here as a convenience.
      #   The type of this field is +String+.
      # connection_id::
      #   The ID of the SCIM connection.
      #   The type of this field is +String+.
      # cursor::
      #   The `cursor` field allows you to paginate through your results. Each result array is limited to 1000 results. If your query returns more than 1000 results, you will need to paginate the responses using the `cursor`. If you receive a response that includes a non-null `next_cursor` in the `results_metadata` object, repeat the search call with the `next_cursor` value set to the `cursor` field to retrieve the next page of results. Continue to make search calls until the `next_cursor` in the response is null.
      #   The type of this field is nilable +String+.
      # limit::
      #   The number of search results to return per page. The default limit is 100. A maximum of 1000 results can be returned by a single search request. If the total size of your result set is greater than one page size, you must paginate the response. See the `cursor` field.
      #   The type of this field is nilable +Integer+.
      #
      # == Returns:
      # An object with the following fields:
      # scim_groups::
      #   A list of SCIM Connection Groups belonging to the connection.
      #   The type of this field is list of +SCIMGroup+ (+object+).
      # status_code::
      #   (no documentation yet)
      #   The type of this field is +Integer+.
      # next_cursor::
      #   The `next_cursor` string is returned when your search result contains more than one page of results. This value is passed into your next search call in the `cursor` field.
      #   The type of this field is nilable +String+.
      #
      # == Method Options:
      # This method supports an optional +StytchB2B::SCIM::Connection::GetGroupsRequestOptions+ object which will modify the headers sent in the HTTP request.
      def get_groups(
        organization_id:,
        connection_id:,
        cursor: nil,
        limit: nil,
        method_options: nil
      )
        headers = {}
        headers = headers.merge(method_options.to_headers) unless method_options.nil?
        query_params = {
          cursor: cursor,
          limit: limit
        }
        request = request_with_query_params("/v1/b2b/scim/#{organization_id}/connection/#{connection_id}", query_params)
        get_request(request, headers)
      end

      # Create a new SCIM Connection.
      #
      # == Parameters:
      # organization_id::
      #   Globally unique UUID that identifies a specific Organization. The `organization_id` is critical to perform operations on an Organization, so be sure to preserve this value. You may also use the organization_slug here as a convenience.
      #   The type of this field is +String+.
      # display_name::
      #   A human-readable display name for the connection.
      #   The type of this field is nilable +String+.
      # identity_provider::
      #   (no documentation yet)
      #   The type of this field is nilable +CreateRequestIdentityProvider+ (string enum).
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      # connection::
      #   The `SCIM Connection` object affected by this API call. See the [SCIM Connection Object](https://stytch.com/docs/b2b/api/scim-connection-object) for complete response field details.
      #   The type of this field is nilable +SCIMConnectionWithToken+ (+object+).
      #
      # == Method Options:
      # This method supports an optional +StytchB2B::SCIM::Connection::CreateRequestOptions+ object which will modify the headers sent in the HTTP request.
      def create(
        organization_id:,
        display_name: nil,
        identity_provider: nil,
        method_options: nil
      )
        headers = {}
        headers = headers.merge(method_options.to_headers) unless method_options.nil?
        request = {}
        request[:display_name] = display_name unless display_name.nil?
        request[:identity_provider] = identity_provider unless identity_provider.nil?

        post_request("/v1/b2b/scim/#{organization_id}/connection", request, headers)
      end

      # Get SCIM Connection.
      #
      # == Parameters:
      # organization_id::
      #   Globally unique UUID that identifies a specific Organization. The `organization_id` is critical to perform operations on an Organization, so be sure to preserve this value. You may also use the organization_slug here as a convenience.
      #   The type of this field is +String+.
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      # connection::
      #   A [SCIM Connection](https://stytch.com/docs/b2b/api/scim-connection-object) connection belonging to the organization (currently limited to one).
      #   The type of this field is nilable +SCIMConnection+ (+object+).
      #
      # == Method Options:
      # This method supports an optional +StytchB2B::SCIM::Connection::GetRequestOptions+ object which will modify the headers sent in the HTTP request.
      def get(
        organization_id:,
        method_options: nil
      )
        headers = {}
        headers = headers.merge(method_options.to_headers) unless method_options.nil?
        query_params = {}
        request = request_with_query_params("/v1/b2b/scim/#{organization_id}/connection", query_params)
        get_request(request, headers)
      end
    end
  end
end
