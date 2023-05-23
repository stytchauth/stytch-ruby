# frozen_string_literal: true

require_relative "../request_helper"

module Stytch
  class Organizations
    include Stytch::RequestHelper
    attr_reader :organizations

    def initialize(connection)
      @connection = connection

      @members = Stytch::Organizations::Members.new(@connection)
    end

    def create(
        organization_name: ,
        organization_slug: ,
        organization_logo_url: ,
        email_allowed_domains: ,
        allowed_auth_methods: ,
        trusted_metadata: nil,
        sso_jit_provisioning: nil,
        email_jit_provisioning: nil,
        email_invites: nil,
        auth_methods: nil,
    )
      request = {
          organization_name: organization_name,
          organization_slug: organization_slug,
          organization_logo_url: organization_logo_url,
          email_allowed_domains: email_allowed_domains,
          allowed_auth_methods: allowed_auth_methods,
      }
      request[:trusted_metadata] = trusted_metadata if trusted_metadata != nil
      request[:sso_jit_provisioning] = sso_jit_provisioning if sso_jit_provisioning != nil
      request[:email_jit_provisioning] = email_jit_provisioning if email_jit_provisioning != nil
      request[:email_invites] = email_invites if email_invites != nil
      request[:auth_methods] = auth_methods if auth_methods != nil

      post_request("/v1/b2b/organizations", request)
    end

    def get(
        organization_id: ,
    )
      request = request_with_query_params()
      get_request(request)
    end

    def update(
        organization_id: ,
        organization_name: nil,
        organization_slug: nil,
        organization_logo_url: nil,
        trusted_metadata: nil,
        sso_default_connection_id: nil,
        sso_jit_provisioning: nil,
        sso_jit_provisioning_allowed_connections: nil,
        email_allowed_domains: nil,
        email_jit_provisioning: nil,
        email_invites: nil,
        auth_methods: nil,
        allowed_auth_methods: nil,
    )
      request = {
          organization_id: organization_id,
      }
      request[:organization_name] = organization_name if organization_name != nil
      request[:organization_slug] = organization_slug if organization_slug != nil
      request[:organization_logo_url] = organization_logo_url if organization_logo_url != nil
      request[:trusted_metadata] = trusted_metadata if trusted_metadata != nil
      request[:sso_default_connection_id] = sso_default_connection_id if sso_default_connection_id != nil
      request[:sso_jit_provisioning] = sso_jit_provisioning if sso_jit_provisioning != nil
      request[:sso_jit_provisioning_allowed_connections] = sso_jit_provisioning_allowed_connections if sso_jit_provisioning_allowed_connections != nil
      request[:email_allowed_domains] = email_allowed_domains if email_allowed_domains != nil
      request[:email_jit_provisioning] = email_jit_provisioning if email_jit_provisioning != nil
      request[:email_invites] = email_invites if email_invites != nil
      request[:auth_methods] = auth_methods if auth_methods != nil
      request[:allowed_auth_methods] = allowed_auth_methods if allowed_auth_methods != nil

      put_request("/v1/b2b/organizations/#{organization_id}", request)
    end

    def delete(
        organization_id: ,
    )
      delete_request(request)
    end

    def member_create(
        organization_id: ,
        email_address: ,
        create_member_as_pending: ,
        is_breakglass: ,
        name: nil,
        trusted_metadata: nil,
        untrusted_metadata: nil,
    )
      request = {
          organization_id: organization_id,
          email_address: email_address,
          create_member_as_pending: create_member_as_pending,
          is_breakglass: is_breakglass,
      }
      request[:name] = name if name != nil
      request[:trusted_metadata] = trusted_metadata if trusted_metadata != nil
      request[:untrusted_metadata] = untrusted_metadata if untrusted_metadata != nil

      post_request("/v1/b2b/organizations/#{organization_id}/members", request)
    end

    def search(
        cursor: ,
        limit: nil,
        query: nil,
    )
      request = {
          cursor: cursor,
      }
      request[:limit] = limit if limit != nil
      request[:query] = query if query != nil

      post_request("/v1/b2b/organizations/search", request)
    end

    def member(
        organization_id: ,
        member_id: nil,
        email_address: nil,
    )
      request = request_with_query_params()
      get_request(request)
    end


    class Members
      include Stytch::RequestHelper

      def initialize(connection)
        @connection = connection

      end

      def organizations_update(
          organization_id: ,
          member_id: ,
          name: nil,
          trusted_metadata: nil,
          untrusted_metadata: nil,
          is_breakglass: nil,
      )
        request = {
            organization_id: organization_id,
            member_id: member_id,
        }
        request[:name] = name if name != nil
        request[:trusted_metadata] = trusted_metadata if trusted_metadata != nil
        request[:untrusted_metadata] = untrusted_metadata if untrusted_metadata != nil
        request[:is_breakglass] = is_breakglass if is_breakglass != nil

        put_request("/v1/b2b/organizations/#{organization_id}/members/#{member_id}", request)
      end

      def organizations_delete(
          organization_id: ,
          member_id: ,
      )
        delete_request(request)
      end

      def search(
          cursor: ,
          organization_ids: ,
          limit: nil,
          query: nil,
      )
        request = {
            cursor: cursor,
            organization_ids: organization_ids,
        }
        request[:limit] = limit if limit != nil
        request[:query] = query if query != nil

        post_request("/v1/b2b/organizations/members/search", request)
      end

      def organizations_delete_password(
          organization_id: ,
          member_password_id: ,
      )
        delete_request(request)
      end


    end
  end
end