# frozen_string_literal: true

RSpec.describe Stytch::IDP do
  let(:mock_connection) { instance_double('connection') }
  let(:mock_policy_cache) { instance_double('policy_cache') }
  let(:project_id) { 'project-test-00000000-0000-0000-0000-000000000000' }
  let(:idp) { described_class.new(mock_connection, project_id, mock_policy_cache) }

  let(:sample_jwt_response) do
    {
      'active' => true,
      'sub' => 'user-test-123',
      'scope' => 'read write',
      'aud' => project_id,
      'exp' => Time.now.to_i + 3600,
      'iat' => Time.now.to_i,
      'iss' => "stytch.com/#{project_id}",
      'nbf' => Time.now.to_i,
      'token_type' => 'access_token',
      'custom_field' => 'custom_value'
    }
  end

  before do
    allow(mock_connection).to receive(:url_prefix).and_return('https://test.stytch.com')
    allow(mock_policy_cache).to receive(:perform_consumer_authorization_check)
  end

  describe '#initialize' do
    it 'initializes with connection, project_id, and policy_cache' do
      expect(idp.instance_variable_get(:@connection)).to eq(mock_connection)
      expect(idp.instance_variable_get(:@project_id)).to eq(project_id)
      expect(idp.instance_variable_get(:@policy_cache)).to eq(mock_policy_cache)
    end

    it 'sets up non_custom_claim_keys' do
      expected_keys = %w[aud exp iat iss jti nbf sub active client_id request_id scope status_code token_type]
      expect(idp.instance_variable_get(:@non_custom_claim_keys)).to eq(expected_keys)
    end
  end

  describe '#introspect_token_network' do
    let(:token) { 'test_token' }
    let(:client_id) { 'client_123' }
    let(:client_secret) { 'secret_456' }

    before do
      allow(idp).to receive(:post_request).and_return(sample_jwt_response)
    end

    context 'when token is active' do
      it 'returns token claims without authorization check' do
        result = idp.introspect_token_network(
          token: token,
          client_id: client_id,
          client_secret: client_secret
        )

        expect(result['subject']).to eq('user-test-123')
        expect(result['scope']).to eq('read write')
        expect(result['audience']).to eq(project_id)
        expect(result['token_type']).to eq('access_token')
        expect(result['custom_claims']).to eq({ 'custom_field' => 'custom_value' })
      end

      it 'performs authorization check when provided' do
        authorization_check = { 'action' => 'read', 'resource_id' => 'users' }

        expect(mock_policy_cache).to receive(:perform_consumer_authorization_check)

        idp.introspect_token_network(
          token: token,
          client_id: client_id,
          authorization_check: authorization_check
        )
      end

      it 'includes client_secret in request when provided' do
        expect(idp).to receive(:post_request)

        idp.introspect_token_network(
          token: token,
          client_id: client_id,
          client_secret: client_secret
        )
      end

      it 'uses default token_type_hint when not provided' do
        expect(idp).to receive(:post_request)

        idp.introspect_token_network(
          token: token,
          client_id: client_id
        )
      end

      it 'uses custom token_type_hint when provided' do
        expect(idp).to receive(:post_request)

        idp.introspect_token_network(
          token: token,
          client_id: client_id,
          token_type_hint: 'refresh_token'
        )
      end
    end

    context 'when token is not active' do
      before do
        allow(idp).to receive(:post_request).and_return({ 'active' => false })
      end

      it 'returns nil' do
        result = idp.introspect_token_network(
          token: token,
          client_id: client_id
        )

        expect(result).to be_nil
      end
    end
  end

  describe '#introspect_access_token_local' do
    let(:access_token) { 'valid_jwt_token' }
    let(:decoded_claims) do
      {
        'sub' => 'user-test-123',
        'scope' => 'read write',
        'aud' => project_id,
        'exp' => Time.now.to_i + 3600,
        'iat' => Time.now.to_i,
        'iss' => "stytch.com/#{project_id}",
        'nbf' => Time.now.to_i,
        'custom_field' => 'custom_value'
      }
    end

    before do
      allow(idp).to receive(:get_jwks).and_return({ 'keys' => [] })
    end

    context 'when JWT is valid' do
      before do
        allow(JWT).to receive(:decode).and_return([decoded_claims])
      end

      it 'returns token claims without authorization check' do
        result = idp.introspect_access_token_local(access_token: access_token)

        expect(result['subject']).to eq('user-test-123')
        expect(result['scope']).to eq('read write')
        expect(result['audience']).to eq(project_id)
        expect(result['token_type']).to eq('access_token')
        expect(result['custom_claims']).to eq({ 'custom_field' => 'custom_value' })
      end

      it 'performs authorization check when provided' do
        authorization_check = { 'action' => 'read', 'resource_id' => 'users' }

        expect(mock_policy_cache).to receive(:perform_consumer_authorization_check)

        idp.introspect_access_token_local(
          access_token: access_token,
          authorization_check: authorization_check
        )
      end

      it 'caches JWKS' do
        # The JWKS is loaded in a lambda, so we need to set up the mock to return something
        allow(idp).to receive(:get_jwks).and_return({ 'keys' => [] })

        idp.introspect_access_token_local(access_token: access_token)
      end
    end

    context 'when JWT is invalid' do
      before do
        allow(JWT).to receive(:decode).and_raise(JWT::DecodeError)
      end

      it 'returns nil' do
        result = idp.introspect_access_token_local(access_token: access_token)
        expect(result).to be_nil
      end
    end

    context 'when JWT has invalid issuer' do
      before do
        allow(JWT).to receive(:decode).and_raise(JWT::InvalidIssuerError)
      end

      it 'raises JWTInvalidIssuerError' do
        expect do
          idp.introspect_access_token_local(access_token: access_token)
        end.to raise_error(Stytch::JWTInvalidIssuerError)
      end
    end

    context 'when JWT has invalid audience' do
      before do
        allow(JWT).to receive(:decode).and_raise(JWT::InvalidAudError)
      end

      it 'raises JWTInvalidAudienceError' do
        expect do
          idp.introspect_access_token_local(access_token: access_token)
        end.to raise_error(Stytch::JWTInvalidAudienceError)
      end
    end

    context 'when JWT is expired' do
      before do
        allow(JWT).to receive(:decode).and_raise(JWT::ExpiredSignature)
      end

      it 'raises JWTExpiredSignatureError' do
        expect do
          idp.introspect_access_token_local(access_token: access_token)
        end.to raise_error(Stytch::JWTExpiredSignatureError)
      end
    end

    context 'when JWT has incorrect algorithm' do
      before do
        allow(JWT).to receive(:decode).and_raise(JWT::IncorrectAlgorithm)
      end

      it 'raises JWTIncorrectAlgorithmError' do
        expect do
          idp.introspect_access_token_local(access_token: access_token)
        end.to raise_error(Stytch::JWTIncorrectAlgorithmError)
      end
    end
  end

  describe '#get_jwks' do
    let(:jwks_response) { { 'keys' => %w[key1 key2] } }

    before do
      allow(idp).to receive(:get_request).and_return(jwks_response)
    end

    it 'fetches JWKS for the project' do
      expect(idp).to receive(:get_request)

      result = idp.get_jwks(project_id: project_id)
      expect(result).to eq(jwks_response)
    end
  end
end
