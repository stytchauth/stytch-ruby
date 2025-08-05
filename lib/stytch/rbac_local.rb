# frozen_string_literal: true

require_relative 'errors'
require_relative 'request_helper'

module Stytch
  class PolicyCache
    def initialize(rbac_client:)
      @rbac_client = rbac_client
      @policy_last_update = 0
      @cached_policy = nil
    end

    def reload_policy
      @cached_policy = @rbac_client.policy['policy']
      @policy_last_update = Time.now.to_i
    end

    def get_policy(invalidate: false)
      reload_policy if invalidate || @cached_policy.nil? || @policy_last_update < Time.now.to_i - 300
      @cached_policy
    end

    # Performs an authorization check against the project's policy and a set of roles. If the
    # check succeeds, this method will return. If the check fails, a PermissionError
    # will be raised. It's also possible for a TenancyError to be raised if the
    # subject_org_id does not match the authZ request organization_id.
    # authorization_check is an object with keys 'action', 'resource_id', and 'organization_id'
    def perform_authorization_check(
      subject_roles:,
      subject_org_id:,
      authorization_check:
    )
      raise Stytch::TenancyError.new(subject_org_id, authorization_check['organization_id']) if subject_org_id != authorization_check['organization_id']

      policy = get_policy

      for role in policy['roles']
        next unless subject_roles.include?(role['role_id'])

        for permission in role['permissions']
          actions = permission['actions']
          resource = permission['resource_id']
          has_matching_action = actions.include?('*') || actions.include?(authorization_check['action'])
          has_matching_resource = resource == authorization_check['resource_id']
          if has_matching_action && has_matching_resource
            # All good
            return
          end
        end
      end

      # If we get here, we didn't find a matching permission
      raise Stytch::PermissionError, authorization_check
    end

    # Performs an authorization check against the project's policy and a set of scopes. If the
    # check succeeds, this method will return. If the check fails, a PermissionError
    # will be raised. This is used for OAuth-style consumer authorization.
    # authorization_check is an object with keys 'action' and 'resource_id'
    def perform_consumer_authorization_check(
      subject_roles:,
      authorization_check:
    )
      policy = get_policy

      # For consumer authorization, we check roles without tenancy validation
      for role in policy['roles']
        next unless subject_roles.include?(role['role_id'])

        for permission in role['permissions']
          actions = permission['actions']
          resource = permission['resource_id']
          has_matching_action = actions.include?('*') || actions.include?(authorization_check['action'])
          has_matching_resource = resource == authorization_check['resource_id']
          if has_matching_action && has_matching_resource
            return # Permission granted
          end
        end
      end

      # If we get here, we didn't find a matching permission
      raise Stytch::PermissionError, authorization_check
    end

    # Performs an authorization check against the project's policy and a set of scopes. If the
    # check succeeds, this method will return. If the check fails, a PermissionError
    # will be raised. This is used for OAuth-style scope-based authorization.
    # authorization_check is an object with keys 'action' and 'resource_id'
    def perform_scope_authorization_check(
      token_scopes:,
      authorization_check:
    )
      policy = get_policy

      # For scope-based authorization, we check if any of the token scopes match policy scopes
      # and if those scopes grant permission for the requested action/resource
      action = authorization_check['action']
      resource_id = authorization_check['resource_id']

      # Check if any of the token scopes grant permission for this action/resource
      for scope_obj in policy['scopes']
        scope_name = scope_obj['scope']
        next unless token_scopes.include?(scope_name)

        # Check if this scope grants permission for the requested action/resource
        for permission in scope_obj['permissions']
          actions = permission['actions']
          resource = permission['resource_id']
          has_matching_action = actions.include?('*') || actions.include?(action)
          has_matching_resource = resource == resource_id
          if has_matching_action && has_matching_resource
            return # Permission granted
          end
        end
      end

      # If we get here, we didn't find a matching permission
      raise Stytch::PermissionError, authorization_check
    end
  end
end
