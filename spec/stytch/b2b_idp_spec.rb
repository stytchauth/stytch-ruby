# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers

require 'spec_helper'
require 'jwt'

RSpec.describe StytchB2B::IDP do
  let(:connection) { instance_double('connection', url_prefix: 'https://test.stytch.com') }
  let(:project_id) { 'project-test-00000000-0000-0000-0000-000000000000' }
  let(:policy_cache) { instance_double('Stytch::PolicyCache') }
  let(:idp) { described_class.new(connection, project_id, policy_cache) }

  describe '#initialize' do
    it 'initializes with connection, project_id, and policy_cache' do
      expect(idp.instance_variable_get(:@connection)).to eq(connection)
      expect(idp.instance_variable_get(:@project_id)).to eq(project_id)
      expect(idp.instance_variable_get(:@policy_cache)).to eq(policy_cache)
    end

    it 'sets up non_custom_claim_keys' do
      expected_keys = [
        'aud', 'exp', 'iat', 'iss', 'jti', 'nbf', 'sub', 'active',
        'client_id', 'request_id', 'scope', 'status_code', 'token_type',
        'https://stytch.com/organization'
      ]
      expect(idp.send(:non_custom_claim_keys)).to eq(expected_keys)
    end
  end

  describe '#introspect_token_network' do
    let(:token) { 'test_token' }
    let(:client_id) { 'test_client_id' }
    let(:client_secret) { 'test_client_secret' }
    let(:token_type_hint) { 'access_token' }
    let(:response) do
      {
        'active' => true,
        'sub' => 'user-123',
        'scope' => 'read write',
        'https://stytch.com/organization' => {
          'organization_id' => 'org-123'
        }
      }
    end

    before do
      allow(idp).to receive(:post_request).and_return(response)
    end

    it 'calls the introspect endpoint with correct parameters' do
      expected_url = connection.url_prefix + '/v1/oauth2/introspect'
      expected_data = {
        'token' => token,
        'client_id' => client_id,
        'client_secret' => client_secret,
        'token_type_hint' => token_type_hint
      }
      expected_headers = {}

      idp.introspect_token_network(
        token: token,
        client_id: client_id,
        client_secret: client_secret,
        token_type_hint: token_type_hint
      )
      expect(idp).to have_received(:post_request).with(expected_url, expected_data, expected_headers)
    end

    context 'when token is not active' do
      let(:response) { { 'active' => false } }

      it 'returns nil when token is not active' do
        result = idp.introspect_token_network(
          token: token,
          client_id: client_id
        )
        expect(result).to be_nil
      end
    end

    context 'when token is active' do
      let(:response) do
        {
          'active' => true,
          'sub' => 'user-123',
          'scope' => 'read write',
          'aud' => ['project-123'],
          'exp' => 1_234_567_890,
          'iat' => 1_234_567_890,
          'iss' => 'stytch.com/project-123',
          'nbf' => 1_234_567_890,
          'token_type' => 'access_token',
          'https://stytch.com/organization' => {
            'organization_id' => 'org-123',
            'slug' => 'test-org'
          },
          'custom_field' => 'custom_value'
        }
      end

      it 'returns token claims when token is active' do
        result = idp.introspect_token_network(
          token: token,
          client_id: client_id
        )
        expect(result).to include(
          'subject' => 'user-123',
          'scope' => 'read write',
          'audience' => ['project-123'],
          'expires_at' => 1_234_567_890,
          'issued_at' => 1_234_567_890,
          'issuer' => 'stytch.com/project-123',
          'not_before' => 1_234_567_890,
          'token_type' => 'access_token',
          'organization_claim' => {
            'organization_id' => 'org-123',
            'slug' => 'test-org'
          }
        )
        expect(result['custom_claims']).to include('custom_field' => 'custom_value')
      end
    end

    context 'with authorization_check' do
      let(:response) do
        {
          'active' => true,
          'sub' => 'user-123',
          'scope' => 'read write',
          'https://stytch.com/organization' => {
            'organization_id' => 'org-123'
          }
        }
      end
      let(:authorization_check) { { 'action' => 'read', 'resource_id' => 'users' } }

      it 'performs authorization check' do
        allow(policy_cache).to receive(:perform_authorization_check).and_return(nil)
        idp.introspect_token_network(
          token: token,
          client_id: client_id,
          authorization_check: authorization_check
        )
        expect(policy_cache).to have_received(:perform_authorization_check).with(
          subject_roles: %w[read write],
          authorization_check: authorization_check,
          subject_org_id: 'org-123'
        )
      end
    end
  end

  describe '#introspect_access_token_local' do
    let(:access_token) { 'test_jwt_token' }
    let(:valid_token) { JWT.encode(decoded_claims, 'secret', 'HS256') }
    let(:decoded_claims) do
      {
        'sub' => 'user-123',
        'scope' => 'read write',
        'aud' => ['project-123'],
        'exp' => 1_234_567_890,
        'iat' => 1_234_567_890,
        'iss' => 'stytch.com/project-123',
        'nbf' => 1_234_567_890,
        'https://stytch.com/organization' => {
          'organization_id' => 'org-123',
          'slug' => 'test-org'
        },
        'custom_field' => 'custom_value'
      }
    end

    before do
      allow(idp).to receive(:get_jwks).and_return({ 'keys' => [] })
      allow(JWT).to receive(:decode).and_return([decoded_claims])
    end

    it 'decodes JWT and returns claims' do
      result = idp.introspect_access_token_local(access_token: access_token)
      expect(result).to include(
        'subject' => 'user-123',
        'scope' => 'read write',
        'audience' => ['project-123'],
        'expires_at' => 1_234_567_890,
        'issued_at' => 1_234_567_890,
        'issuer' => 'stytch.com/project-123',
        'not_before' => 1_234_567_890,
        'token_type' => 'access_token',
        'organization_claim' => {
          'organization_id' => 'org-123',
          'slug' => 'test-org'
        }
      )
      expect(result['custom_claims']).to include('custom_field' => 'custom_value')
    end

    it 'returns nil when JWT decoding fails' do
      allow(JWT).to receive(:decode).and_raise(JWT::DecodeError)
      result = idp.introspect_access_token_local(access_token: access_token)
      expect(result).to be_nil
    end

    it 'returns not nil when JWT decoding succeeds' do
      result = idp.introspect_access_token_local(access_token: valid_token)
      expect(result).not_to be_nil
    end

    it 'correctly decodes JWT with custom domain issuer' do
      custom_domain_connection = instance_double('connection', url_prefix: 'https://api.custom-domain.com')
      custom_domain_idp = StytchB2B::IDP.new(custom_domain_connection, 'project-123', policy_cache)

      custom_claims = {
        'sub' => 'user-123',
        'scope' => 'read write',
        'aud' => ['project-123'],
        'exp' => 1_234_567_890,
        'iat' => 1_234_567_890,
        'iss' => 'https://api.custom-domain.com', # Using custom domain as issuer
        'nbf' => 1_234_567_890,
        'https://stytch.com/organization' => {
          'organization_id' => 'org-123',
          'slug' => 'test-org'
        },
        'custom_field' => 'custom_value'
      }

      allow(custom_domain_idp).to receive(:get_jwks).and_return({ 'keys' => [] })
      allow(JWT).to receive(:decode).and_return([custom_claims])

      result = custom_domain_idp.introspect_access_token_local(access_token: access_token)
      expect(result).to include(
        'subject' => 'user-123',
        'scope' => 'read write',
        'audience' => ['project-123'],
        'expires_at' => 1_234_567_890,
        'issued_at' => 1_234_567_890,
        'issuer' => 'https://api.custom-domain.com',
        'not_before' => 1_234_567_890,
        'token_type' => 'access_token',
        'organization_claim' => {
          'organization_id' => 'org-123',
          'slug' => 'test-org'
        }
      )
      expect(result['custom_claims']).to include('custom_field' => 'custom_value')
    end

    context 'with authorization_check' do
      let(:authorization_check) { { 'action' => 'read', 'resource_id' => 'users' } }

      it 'performs authorization check' do
        allow(policy_cache).to receive(:perform_authorization_check).and_return(nil)
        idp.introspect_access_token_local(
          access_token: access_token,
          authorization_check: authorization_check
        )
        expect(policy_cache).to have_received(:perform_authorization_check).with(
          subject_roles: %w[read write],
          authorization_check: authorization_check,
          subject_org_id: 'org-123'
        )
      end
    end
  end
end

# rubocop:enable RSpec/MultipleMemoizedHelpers
