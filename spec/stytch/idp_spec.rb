# frozen_string_literal: true

RSpec.describe Stytch::IDP do
  let(:mock_connection) { instance_double('connection') }
  let(:mock_policy_cache) { instance_double('policy_cache') }
  let(:project_id) { 'project-test-00000000-0000-0000-0000-000000000000' }
  let(:idp) { described_class.new(mock_connection, project_id, mock_policy_cache) }

  before do
    allow(mock_connection).to receive(:url_prefix).and_return('https://test.stytch.com')
    allow(mock_policy_cache).to receive(:perform_scope_authorization_check)
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
    before do
      allow(idp).to receive(:post_request).and_return(
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
      )
    end

    context 'when token is active' do
      it 'returns token claims without authorization check' do
        result = idp.introspect_token_network(
          token: 'test_token',
          client_id: 'client_123',
          client_secret: 'secret_456'
        )

        expect(result['subject']).to eq('user-test-123')
        expect(result['scope']).to eq('read write')
        expect(result['audience']).to eq(project_id)
        expect(result['token_type']).to eq('access_token')
        expect(result['custom_claims']).to eq({ 'custom_field' => 'custom_value' })
      end

      it 'performs authorization check when provided' do
        authorization_check = { 'action' => 'read', 'resource_id' => 'users' }

        idp.introspect_token_network(
          token: 'test_token',
          client_id: 'client_123',
          authorization_check: authorization_check
        )

        expect(mock_policy_cache).to have_received(:perform_scope_authorization_check)
      end

      it 'includes client_secret in request when provided' do
        idp.introspect_token_network(
          token: 'test_token',
          client_id: 'client_123',
          client_secret: 'secret_456'
        )

        expect(idp).to have_received(:post_request)
      end

      it 'uses default token_type_hint when not provided' do
        idp.introspect_token_network(
          token: 'test_token',
          client_id: 'client_123'
        )

        expect(idp).to have_received(:post_request)
      end

      it 'uses custom token_type_hint when provided' do
        idp.introspect_token_network(
          token: 'test_token',
          client_id: 'client_123',
          token_type_hint: 'refresh_token'
        )

        expect(idp).to have_received(:post_request)
      end
    end

    context 'when token is not active' do
      before do
        allow(idp).to receive(:post_request).and_return({ 'active' => false })
      end

      it 'returns nil' do
        result = idp.introspect_token_network(
          token: 'test_token',
          client_id: 'client_123'
        )

        expect(result).to be_nil
      end
    end
  end

  describe '#introspect_access_token_local' do
    before do
      allow(idp).to receive(:get_jwks).and_return({ 'keys' => [] })
    end

    context 'when JWT is valid' do
      before do
        allow(JWT).to receive(:decode).and_return([{
                                                    'sub' => 'user-test-123',
                                                    'scope' => 'read write',
                                                    'aud' => project_id,
                                                    'exp' => Time.now.to_i + 3600,
                                                    'iat' => Time.now.to_i,
                                                    'iss' => "stytch.com/#{project_id}",
                                                    'nbf' => Time.now.to_i,
                                                    'custom_field' => 'custom_value'
                                                  }])
      end

      it 'returns token claims without authorization check' do
        result = idp.introspect_access_token_local(access_token: 'valid_jwt_token')

        expect(result['subject']).to eq('user-test-123')
        expect(result['scope']).to eq('read write')
        expect(result['audience']).to eq(project_id)
        expect(result['token_type']).to eq('access_token')
        expect(result['custom_claims']).to eq({ 'custom_field' => 'custom_value' })
      end

      it 'performs authorization check when provided' do
        authorization_check = { 'action' => 'read', 'resource_id' => 'users' }

        idp.introspect_access_token_local(
          access_token: 'valid_jwt_token',
          authorization_check: authorization_check
        )

        expect(mock_policy_cache).to have_received(:perform_scope_authorization_check)
      end

      it 'caches JWKS' do
        # The JWKS is loaded in a lambda, so we need to set up the mock to return something
        allow(idp).to receive(:get_jwks).and_return({ 'keys' => [] })

        idp.introspect_access_token_local(access_token: 'valid_jwt_token')
      end
    end

    context 'when JWT is invalid' do
      before do
        allow(JWT).to receive(:decode).and_raise(JWT::DecodeError)
      end

      it 'returns nil' do
        result = idp.introspect_access_token_local(access_token: 'invalid_jwt_token')
        expect(result).to be_nil
      end
    end

    context 'when JWT has invalid issuer' do
      before do
        allow(JWT).to receive(:decode).and_raise(JWT::InvalidIssuerError)
      end

      it 'raises JWTInvalidIssuerError' do
        expect do
          idp.introspect_access_token_local(access_token: 'invalid_issuer_token')
        end.to raise_error(Stytch::JWTInvalidIssuerError)
      end
    end

    context 'when JWT has invalid audience' do
      before do
        allow(JWT).to receive(:decode).and_raise(JWT::InvalidAudError)
      end

      it 'raises JWTInvalidAudienceError' do
        expect do
          idp.introspect_access_token_local(access_token: 'invalid_audience_token')
        end.to raise_error(Stytch::JWTInvalidAudienceError)
      end
    end

    context 'when JWT is expired' do
      before do
        allow(JWT).to receive(:decode).and_raise(JWT::ExpiredSignature)
      end

      it 'raises JWTExpiredSignatureError' do
        expect do
          idp.introspect_access_token_local(access_token: 'expired_token')
        end.to raise_error(Stytch::JWTExpiredSignatureError)
      end
    end

    context 'when JWT has incorrect algorithm' do
      before do
        allow(JWT).to receive(:decode).and_raise(JWT::IncorrectAlgorithm)
      end

      it 'raises JWTIncorrectAlgorithmError' do
        expect do
          idp.introspect_access_token_local(access_token: 'incorrect_algorithm_token')
        end.to raise_error(Stytch::JWTIncorrectAlgorithmError)
      end
    end
  end

  describe '#get_jwks' do
    before do
      allow(idp).to receive(:get_request).and_return({ 'keys' => %w[key1 key2] })
    end

    it 'fetches JWKS for the project' do
      result = idp.get_jwks(project_id: project_id)

      expect(idp).to have_received(:get_request)
      expect(result).to eq({ 'keys' => %w[key1 key2] })
    end
  end
end
