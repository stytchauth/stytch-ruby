# frozen_string_literal: true

require_relative 'request_helper'

module StytchB2B
  class Organizations
    include Stytch::RequestHelper
    attr_reader :members

    def initialize(connection)
      @connection = connection

      @members = StytchB2B::Organizations::Members.new(@connection)
    end

    def create(
      organization_name:,
      organization_slug:,
      organization_logo_url: nil,
      trusted_metadata: nil,
      sso_jit_provisioning: nil,
      email_allowed_domains: nil,
      email_jit_provisioning: nil,
      email_invites: nil,
      auth_methods: nil,
      allowed_auth_methods: nil
    )
      request = {
        organization_name: organization_name,
        organization_slug: organization_slug
      }
      request[:organization_logo_url] = organization_logo_url unless organization_logo_url.nil?
      request[:trusted_metadata] = trusted_metadata unless trusted_metadata.nil?
      request[:sso_jit_provisioning] = sso_jit_provisioning unless sso_jit_provisioning.nil?
      request[:email_allowed_domains] = email_allowed_domains unless email_allowed_domains.nil?
      request[:email_jit_provisioning] = email_jit_provisioning unless email_jit_provisioning.nil?
      request[:email_invites] = email_invites unless email_invites.nil?
      request[:auth_methods] = auth_methods unless auth_methods.nil?
      request[:allowed_auth_methods] = allowed_auth_methods unless allowed_auth_methods.nil?

      post_request('/v1/b2b/organizations', request)
    end

    def get(
      organization_id:
    )
      query_params = {
        organization_id: organization_id
      }
      request = request_with_query_params("/v1/b2b/organizations/#{organization_id}", query_params)
      get_request(request)
    end

    def update(
      organization_id:,
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
      allowed_auth_methods: nil
    )
      request = {
        organization_id: organization_id
      }
      request[:organization_name] = organization_name unless organization_name.nil?
      request[:organization_slug] = organization_slug unless organization_slug.nil?
      request[:organization_logo_url] = organization_logo_url unless organization_logo_url.nil?
      request[:trusted_metadata] = trusted_metadata unless trusted_metadata.nil?
      request[:sso_default_connection_id] = sso_default_connection_id unless sso_default_connection_id.nil?
      request[:sso_jit_provisioning] = sso_jit_provisioning unless sso_jit_provisioning.nil?
      unless sso_jit_provisioning_allowed_connections.nil?
        request[:sso_jit_provisioning_allowed_connections] =
          sso_jit_provisioning_allowed_connections
      end
      request[:email_allowed_domains] = email_allowed_domains unless email_allowed_domains.nil?
      request[:email_jit_provisioning] = email_jit_provisioning unless email_jit_provisioning.nil?
      request[:email_invites] = email_invites unless email_invites.nil?
      request[:auth_methods] = auth_methods unless auth_methods.nil?
      request[:allowed_auth_methods] = allowed_auth_methods unless allowed_auth_methods.nil?

      put_request("/v1/b2b/organizations/#{organization_id}", request)
    end

    def delete(
      organization_id:
    )
      delete_request("/v1/b2b/organizations/#{organization_id}")
    end

    def search(
      cursor: nil,
      limit: nil,
      query: nil
    )
      request = {}
      request[:cursor] = cursor unless cursor.nil?
      request[:limit] = limit unless limit.nil?
      request[:query] = query unless query.nil?

      post_request('/v1/b2b/organizations/search', request)
    end

    class Members
      include Stytch::RequestHelper

      def initialize(connection)
        @connection = connection
      end

      def create(
        organization_id:,
        email_address:,
        name: nil,
        trusted_metadata: nil,
        untrusted_metadata: nil,
        create_member_as_pending: nil,
        is_breakglass: nil
      )
        request = {
          organization_id: organization_id,
          email_address: email_address
        }
        request[:name] = name unless name.nil?
        request[:trusted_metadata] = trusted_metadata unless trusted_metadata.nil?
        request[:untrusted_metadata] = untrusted_metadata unless untrusted_metadata.nil?
        request[:create_member_as_pending] = create_member_as_pending unless create_member_as_pending.nil?
        request[:is_breakglass] = is_breakglass unless is_breakglass.nil?

        post_request("/v1/b2b/organizations/#{organization_id}/members", request)
      end

      def get(
        organization_id:,
        member_id: nil,
        email_address: nil
      )
        query_params = {
          organization_id: organization_id,
          member_id: member_id,
          email_address: email_address
        }
        request = request_with_query_params("/v1/b2b/organizations/#{organization_id}/member", query_params)
        get_request(request)
      end

      def update(
        organization_id:,
        member_id:,
        name: nil,
        trusted_metadata: nil,
        untrusted_metadata: nil,
        is_breakglass: nil
      )
        request = {
          organization_id: organization_id,
          member_id: member_id
        }
        request[:name] = name unless name.nil?
        request[:trusted_metadata] = trusted_metadata unless trusted_metadata.nil?
        request[:untrusted_metadata] = untrusted_metadata unless untrusted_metadata.nil?
        request[:is_breakglass] = is_breakglass unless is_breakglass.nil?

        put_request("/v1/b2b/organizations/#{organization_id}/members/#{member_id}", request)
      end

      def delete(
        organization_id:,
        member_id:
      )
        delete_request("/v1/b2b/organizations/#{organization_id}/members/#{member_id}")
      end

      def search(
        organization_ids:,
        cursor: nil,
        limit: nil,
        query: nil
      )
        request = {
          organization_ids: organization_ids
        }
        request[:cursor] = cursor unless cursor.nil?
        request[:limit] = limit unless limit.nil?
        request[:query] = query unless query.nil?

        post_request('/v1/b2b/organizations/members/search', request)
      end

      def organizations_delete_password(
        organization_id:,
        member_password_id:
      )
        delete_request("/v1/b2b/organizations/#{organization_id}/members/passwords/#{member_password_id}")
      end
    end
  end
end
