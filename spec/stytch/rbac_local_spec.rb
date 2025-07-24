# frozen_string_literal: true

RSpec.describe Stytch::PolicyCache do
  let(:mock_rbac_client) { double('rbac_client') }
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

  before do
    allow(mock_rbac_client).to receive(:policy).and_return({ 'policy' => sample_policy })
  end

  describe '#initialize' do
    it 'initializes with rbac_client' do
      expect(policy_cache.instance_variable_get(:@rbac_client)).to eq(mock_rbac_client)
      expect(policy_cache.instance_variable_get(:@policy_last_update)).to eq(0)
      expect(policy_cache.instance_variable_get(:@cached_policy)).to be_nil
    end
  end

  describe '#reload_policy' do
    it 'reloads policy from rbac_client' do
      policy_cache.reload_policy
      expect(policy_cache.instance_variable_get(:@cached_policy)).to eq(sample_policy)
      expect(policy_cache.instance_variable_get(:@policy_last_update)).to be > 0
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

  describe '#perform_authorization_check' do
    let(:authorization_check) do
      {
        'action' => 'read',
        'resource_id' => 'users',
        'organization_id' => 'org-123'
      }
    end

    context 'when subject_org_id is provided' do
      context 'and matches request organization_id' do
        it 'passes tenancy check and proceeds with authorization' do
          expect {
            policy_cache.perform_authorization_check(
              subject_roles: ['user'],
              subject_org_id: 'org-123',
              authorization_check: authorization_check
            )
          }.not_to raise_error
        end
      end

      context 'and does not match request organization_id' do
        it 'raises TenancyError' do
          expect {
            policy_cache.perform_authorization_check(
              subject_roles: ['user'],
              subject_org_id: 'org-456',
              authorization_check: authorization_check
            )
          }.to raise_error(Stytch::TenancyError)
        end
      end
    end

    context 'when subject_org_id is nil' do
      it 'skips tenancy check and proceeds with authorization' do
        expect {
          policy_cache.perform_authorization_check(
            subject_roles: ['user'],
            subject_org_id: nil,
            authorization_check: authorization_check
          )
        }.not_to raise_error
      end


    end

    context 'when subject_org_id is not provided (uses default nil)' do
      it 'skips tenancy check and proceeds with authorization' do
        expect {
          policy_cache.perform_authorization_check(
            subject_roles: ['user'],
            authorization_check: authorization_check
          )
        }.not_to raise_error
      end
    end

    context 'authorization checks' do
      context 'when user has matching role and permission' do
        it 'succeeds for wildcard action' do
          expect {
            policy_cache.perform_authorization_check(
              subject_roles: ['admin'],
              authorization_check: {
                'action' => 'any_action',
                'resource_id' => 'users',
                'organization_id' => 'org-123'
              }
            )
          }.not_to raise_error
        end

        it 'succeeds for specific action' do
          expect {
            policy_cache.perform_authorization_check(
              subject_roles: ['user'],
              authorization_check: {
                'action' => 'read',
                'resource_id' => 'users',
                'organization_id' => 'org-123'
              }
            )
          }.not_to raise_error
        end
      end

      context 'when user has role but no matching permission' do
        it 'raises PermissionError' do
          expect {
            policy_cache.perform_authorization_check(
              subject_roles: ['user'],
              authorization_check: {
                'action' => 'write',
                'resource_id' => 'users',
                'organization_id' => 'org-123'
              }
            )
          }.to raise_error(Stytch::PermissionError)
        end
      end

      context 'when user has no matching role' do
        it 'raises PermissionError' do
          expect {
            policy_cache.perform_authorization_check(
              subject_roles: ['guest'],
              authorization_check: authorization_check
            )
          }.to raise_error(Stytch::PermissionError)
        end
      end

      context 'when user has multiple roles' do
        it 'succeeds if any role has permission' do
          expect {
            policy_cache.perform_authorization_check(
              subject_roles: ['guest', 'user'],
              authorization_check: {
                'action' => 'write',
                'resource_id' => 'posts',
                'organization_id' => 'org-123'
              }
            )
          }.not_to raise_error
        end
      end
    end
  end
end
