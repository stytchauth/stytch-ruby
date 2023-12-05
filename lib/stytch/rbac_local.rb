# frozen_string_literal: true

require_relative 'request_helper'

module StytchB2B
  class PolicyCache
    def initialize(rbac_client:)
      @policy_last_update = 0
      @cached_policy = nil
    end

    def reload_policy
      @cached_policy = rbac_client.get_policy
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
    # authz_request is an object with keys 'action', 'resource_id', and 'organization_id'
    def perform_authorization_check(
      subject_roles:,
      subject_org_id:,
      authz_request:
    )
      raise TenancyError, subject_org_id if subject_org_id != authz_request['organization_id']

      policy = get_policy

      for role in policy['roles']
        next unless subject_roles.include?(role['role_id'])

        for permission in role['permissions']
          actions = permission['actions']
          resource = permission['resource_id']
          has_matching_action = actions.include?('*') || actions.include?(authz_request['action'])
          has_matching_resource = resource == authz_request['resource_id']
          if has_matching_action && has_matching_resource
            # All good
            return
          end
        end
      end

      # If we get here, we didn't find a matching permission
      raise PermissionError, authz_request
    end
  end
end
