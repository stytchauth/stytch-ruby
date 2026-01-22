# frozen_string_literal: true

RSpec.describe Stytch::PolicyCache do
  let(:mock_organizations) { instance_double('Organizations') }
  let(:mock_rbac_client) { instance_double('rbac_client', organizations: mock_organizations) }

  let(:policy_cache) { described_class.new(rbac_client: mock_rbac_client) }

  let(:sample_policy) do
    {
      'roles' => [
        {
          'role_id' => 'admin',
          'permissions' => [
            {
              'actions' => ['*'],
              'resource_id' => 'users'
            }
          ]
        },
        {
          'role_id' => 'user',
          'permissions' => [
            {
              'actions' => ['read'],
              'resource_id' => 'users'
            },
            {
              'actions' => ['write'],
              'resource_id' => 'posts'
            }
          ]
        }
      ]
    }
  end

  let(:sample_org_policy) do
    {
      'roles' => [
        {
          'role_id' => 'resident',
          'permissions' => [
            {
              'resource_id' => 'fridge',
              'actions' => ['*']
            }
          ]
        },
        {
          'role_id' => 'shopper',
          'permissions' => [
            {
              'resource_id' => 'fridge',
              'actions' => ['stock']
            }
          ]
        }
      ]
    }
  end

  before do
    allow(mock_rbac_client).to receive(:policy).and_return({ 'policy' => sample_policy })
    allow(mock_organizations).to receive(:get_org_policy).and_return('org_policy' => sample_org_policy)
  end

  describe '#initialize' do
    it 'initializes with rbac_client' do
      expect(policy_cache.instance_variable_get(:@rbac_client)).to eq(mock_rbac_client)
      expect(policy_cache.instance_variable_get(:@policy_last_update)).to eq(0)
      expect(policy_cache.instance_variable_get(:@cached_policy)).to be_nil
      expect(policy_cache.instance_variable_get(:@cached_org_policies)).to eq({})
    end
  end

  describe '#reload_policy' do
    it 'reloads policy from rbac_client' do
      policy_cache.reload_policy
      expect(policy_cache.instance_variable_get(:@cached_policy)).to eq(sample_policy)
      expect(policy_cache.instance_variable_get(:@policy_last_update)).to be > 0
    end
  end

  describe '#reload_org_policy' do
    it 'reloads org policy from rbac_client' do
      policy_cache.reload_org_policy(organization_id: 'org-123')

      cache = policy_cache.instance_variable_get(:@cached_org_policies)
      cached_org_policy = cache['org-123'].instance_variable_get(:@org_policy)
      expect(cached_org_policy).to eq(sample_org_policy)
    end
  end

  describe '#get_policy' do
    context 'when cache is empty' do
      it 'reloads policy' do
        result = policy_cache.get_policy
        expect(result).to eq(sample_policy)
      end
    end

    context 'when cache is stale' do
      before do
        policy_cache.instance_variable_set(:@policy_last_update, Time.now.to_i - 400)
        policy_cache.instance_variable_set(:@cached_policy, { 'old' => 'policy' })
      end

      it 'reloads policy' do
        result = policy_cache.get_policy
        expect(result).to eq(sample_policy)
      end
    end

    context 'when cache is fresh' do
      before do
        policy_cache.instance_variable_set(:@policy_last_update, Time.now.to_i - 100)
        policy_cache.instance_variable_set(:@cached_policy, { 'cached' => 'policy' })
      end

      it 'returns cached policy' do
        result = policy_cache.get_policy
        expect(result).to eq({ 'cached' => 'policy' })
      end
    end

    context 'when invalidate is true' do
      before do
        policy_cache.instance_variable_set(:@cached_policy, { 'cached' => 'policy' })
      end

      it 'reloads policy' do
        result = policy_cache.get_policy(invalidate: true)
        expect(result).to eq(sample_policy)
      end
    end
  end

  describe '#get_org_policy' do
    before(:all) do
      @org_id = 'org-123'
    end

    context 'when cache is empty' do
      it 'reloads org policy' do
        result = policy_cache.get_org_policy(organization_id: @org_id)
        expect(result).to eq(sample_org_policy)
      end
    end

    context 'when cache is stale' do
      before do
        cached_org_policy = Stytch::CachedOrgPolicy.new(org_policy: sample_org_policy)
        # Clear the Org policy roles so we can ensure it gets properly refreshed.
        cached_org_policy.instance_variable_set(:@org_policy, { 'roles' => [] })
        cached_org_policy.instance_variable_set(:@last_update, Time.now.to_i - 400)

        policy_cache.instance_variable_set(:@cached_org_policies, {
                                             @org_id.to_s => cached_org_policy
                                           })
      end

      it 'reloads policy' do
        result = policy_cache.get_org_policy(organization_id: @org_id)
        expect(result).to eq(sample_org_policy)
      end
    end

    context 'when cache is fresh' do
      before do
        cached_org_policy = Stytch::CachedOrgPolicy.new(org_policy: { 'org_policy' => 'policy' })
        cached_org_policy.instance_variable_set(:@last_update, Time.now.to_i - 100)
        policy_cache.instance_variable_set(:@cached_org_policies, {
                                             @org_id.to_s => cached_org_policy
                                           })
      end

      it 'returns cached policy' do
        result = policy_cache.get_org_policy(organization_id: @org_id)
        expect(result).to eq('policy')
      end
    end

    context 'when invalidate is true' do
      before do
        cached_org_policy = Stytch::CachedOrgPolicy.new(org_policy: { 'org_policy' => 'policy' })
        cached_org_policy.instance_variable_set(:@last_update, Time.now.to_i - 100)
        policy_cache.instance_variable_set(:@cached_org_policies, {
                                             @org_id.to_s => cached_org_policy
                                           })
      end

      it 'reloads policy' do
        result = policy_cache.get_org_policy(organization_id: @org_id, invalidate: true)
        expect(result).to eq(sample_org_policy)
      end
    end
  end

  describe '#perform_authorization_check' do
    let(:authorization_check) do
      {
        'action' => 'read',
        'resource_id' => 'users',
        'organization_id' => 'org-123'
      }
    end

    context 'when subject_org_id matches request organization_id' do
      it 'passes tenancy check and proceeds with authorization' do
        expect do
          policy_cache.perform_authorization_check(
            subject_roles: ['user'],
            subject_org_id: 'org-123',
            authorization_check: authorization_check
          )
        end.not_to raise_error
      end
    end

    context 'when subject_org_id does not match request organization_id' do
      it 'raises TenancyError' do
        expect do
          policy_cache.perform_authorization_check(
            subject_roles: ['user'],
            subject_org_id: 'org-456',
            authorization_check: authorization_check
          )
        end.to raise_error(Stytch::TenancyError)
      end
    end

    it 'succeeds for wildcard action when user has admin role' do
      expect do
        policy_cache.perform_authorization_check(
          subject_roles: ['admin'],
          authorization_check: {
            'action' => 'any_action',
            'resource_id' => 'users',
            'organization_id' => 'org-123'
          },
          subject_org_id: 'org-123'
        )
      end.not_to raise_error
    end

    it 'succeeds for specific action when user has matching role and permission' do
      expect do
        policy_cache.perform_authorization_check(
          subject_roles: ['shopper'],
          authorization_check: {
            'action' => 'stock',
            'resource_id' => 'fridge',
            'organization_id' => 'org-123'
          },
          subject_org_id: 'org-123'
        )
      end.not_to raise_error
    end

    it 'raises PermissionError when user has role but no matching permission' do
      expect do
        policy_cache.perform_authorization_check(
          subject_roles: ['user'],
          authorization_check: {
            'action' => 'write',
            'resource_id' => 'users',
            'organization_id' => 'org-123'
          },
          subject_org_id: 'org-123'
        )
      end.to raise_error(Stytch::PermissionError)
    end

    it 'succeeds if any role has permission when user has multiple roles' do
      expect do
        policy_cache.perform_authorization_check(
          subject_roles: %w[guest user resident],
          authorization_check: {
            'action' => 'write',
            'resource_id' => 'posts',
            'organization_id' => 'org-123'
          },
          subject_org_id: 'org-123'
        )
      end.not_to raise_error
    end
  end

  describe '#perform_consumer_authorization_check' do
    let(:authorization_check) do
      {
        'action' => 'read',
        'resource_id' => 'users'
      }
    end

    it 'succeeds for wildcard action when user has admin role' do
      expect do
        policy_cache.perform_consumer_authorization_check(
          subject_roles: ['admin'],
          authorization_check: {
            'action' => 'any_action',
            'resource_id' => 'users'
          }
        )
      end.not_to raise_error
    end

    it 'succeeds for specific action when user has matching role and permission' do
      expect do
        policy_cache.perform_consumer_authorization_check(
          subject_roles: ['user'],
          authorization_check: {
            'action' => 'read',
            'resource_id' => 'users'
          }
        )
      end.not_to raise_error
    end

    it 'raises PermissionError when user has role but no matching permission' do
      expect do
        policy_cache.perform_consumer_authorization_check(
          subject_roles: ['user'],
          authorization_check: {
            'action' => 'write',
            'resource_id' => 'users'
          }
        )
      end.to raise_error(Stytch::PermissionError)
    end

    it 'raises PermissionError when user has no matching role' do
      expect do
        policy_cache.perform_consumer_authorization_check(
          subject_roles: ['guest'],
          authorization_check: authorization_check
        )
      end.to raise_error(Stytch::PermissionError)
    end

    it 'succeeds if any role has permission when user has multiple roles' do
      expect do
        policy_cache.perform_consumer_authorization_check(
          subject_roles: %w[guest user],
          authorization_check: {
            'action' => 'write',
            'resource_id' => 'posts'
          }
        )
      end.not_to raise_error
    end
  end
end
