# frozen_string_literal: true

RSpec.describe StytchB2B::IDP do
  let(:connection) { instance_double('connection', url_prefix: 'https://test.stytch.com') }
  let(:project_id) { 'project-test-00000000-0000-0000-0000-000000000000' }
  let(:policy_cache) { instance_double('policy_cache') }
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
      expect(idp.instance_variable_get(:@non_custom_claim_keys)).to eq(expected_keys)
    end
  end

  describe '#introspect_token_network' do
    let(:token) { 'test_token' }
    let(:client_id) { 'test_client_id' }
    let(:client_secret) { 'test_client_secret' }
    let(:token_type_hint) { 'access_token' }
    let(:mock_response) do
      {
        'active' => true,
        'sub' => 'user-123',
        'scope' => 'read write',
        'aud' => 'test_audience',
        'exp' => 1234567890,
        'iat' => 1234567890,
        'iss' => 'test_issuer',
        'nbf' => 1234567890,
        'token_type' => 'access_token',
        'https://stytch.com/organization' => { 'organization_id' => 'org-123' },
        'custom_field' => 'custom_value'
      }
    end

    before do
      allow(idp).to receive(:post_request).and_return(mock_response)
    end

    it 'calls the introspect endpoint with correct parameters' do
      expected_url = "/v1/public/#{project_id}/oauth2/introspect"
      expected_data = {
        'token' => token,
        'client_id' => client_id,
        'token_type_hint' => token_type_hint,
        'client_secret' => client_secret
      }
      expected_headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      idp.introspect_token_network(
        token: token,
        client_id: client_id,
        client_secret: client_secret,
        token_type_hint: token_type_hint
      )

      expect(idp).to have_received(:post_request).with(expected_url, expected_data, expected_headers)
    end

    it 'returns nil when token is not active' do
      inactive_response = mock_response.merge('active' => false)
      allow(idp).to receive(:post_request).and_return(inactive_response)

      result = idp.introspect_token_network(
        token: token,
        client_id: client_id
      )

      expect(result).to be_nil
    end

    it 'returns token claims when token is active' do
      result = idp.introspect_token_network(
        token: token,
        client_id: client_id
      )

      expect(result).to include(
        'subject' => 'user-123',
        'scope' => 'read write',
        'audience' => 'test_audience',
        'expires_at' => 1234567890,
        'issued_at' => 1234567890,
        'issuer' => 'test_issuer',
        'not_before' => 1234567890,
        'token_type' => 'access_token',
        'custom_claims' => { 'custom_field' => 'custom_value' },
        'organization_claim' => { 'organization_id' => 'org-123' }
      )
    end

    context 'with authorization_check' do
      let(:authorization_check) { { 'action' => 'read', 'resource_id' => 'users' } }

      it 'performs authorization check' do
        allow(policy_cache).to receive(:perform_authorization_check).and_return(nil)

        idp.introspect_token_network(
          token: token,
          client_id: client_id,
          authorization_check: authorization_check
        )

        expect(policy_cache).to have_received(:perform_authorization_check).with(
          subject_roles: ['read', 'write'],
          authorization_check: authorization_check,
          subject_org_id: 'org-123'
        )
      end
    end
  end

  describe '#introspect_access_token_local' do
    let(:access_token) { 'test_access_token' }
    let(:kid) { 'jwk-test-00000000-0000-0000-0000-000000000000' }
    let(:claims) do
      {
        'sub' => 'user-123',
        'scope' => 'read write',
        'aud' => 'test_audience',
        'exp' => 1234567890,
        'iat' => 1234567890,
        'iss' => 'stytch.com/' + project_id,
        'nbf' => 1234567890,
        'https://stytch.com/organization' => { 'organization_id' => 'org-123' },
        'custom_field' => 'custom_value'
      }
    end

    before do
      allow(idp).to receive(:get_jwks).and_return({ 'keys' => [] })
      allow(JWT).to receive(:decode).and_return([claims])
    end

    it 'decodes JWT and returns claims' do
      result = idp.introspect_access_token_local(access_token: access_token)

      expect(result).to include(
        'subject' => 'user-123',
        'scope' => 'read write',
        'audience' => 'test_audience',
        'expires_at' => 1234567890,
        'issued_at' => 1234567890,
        'issuer' => 'stytch.com/' + project_id,
        'not_before' => 1234567890,
        'token_type' => 'access_token',
        'custom_claims' => { 'custom_field' => 'custom_value' },
        'organization_claim' => { 'organization_id' => 'org-123' }
      )
    end

    it 'returns nil when JWT decoding fails' do
      allow(JWT).to receive(:decode).and_raise(JWT::DecodeError)

      result = idp.introspect_access_token_local(access_token: access_token)

      expect(result).to be_nil
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
          subject_roles: ['read', 'write'],
          authorization_check: authorization_check,
          subject_org_id: 'org-123'
        )
      end
    end
  end
end 