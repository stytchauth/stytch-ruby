# frozen_string_literal: true

require 'jwt'
require 'openssl'
require 'ostruct'

# Mock connection class for testing
class MockConnection
  attr_reader :url_prefix
  attr_accessor :mock_responses

  def initialize(api_host = 'https://test.stytch.com')
    @url_prefix = api_host
    @mock_responses = {}
  end

  def get(path, _headers)
    # Return a mock response object with a body method
    OpenStruct.new(body: @mock_responses[path] || { 'keys' => [] })
  end
end

RSpec.describe Stytch::JWKSCache do
  let(:project_id) { 'project-test-00000000-0000-0000-0000-000000000000' }
  let(:mock_connection) { MockConnection.new }
  let(:test_jwk) do
    JWT::JWK.new(OpenSSL::PKey::RSA.new(2048), 'test-key-id').export
  end

  describe '#initialize' do
    context 'with manual JWKS provided' do
      it 'caches the provided JWKS immediately' do
        manual_jwks = [test_jwk]
        cache = described_class.new(mock_connection, project_id, manual_jwks)

        # Access the loader to trigger caching logic
        loader = cache.loader
        result = loader.call({})

        expect(result[:keys]).to eq(manual_jwks)
      end

      it 'sets cache timestamp when manual JWKS provided' do
        manual_jwks = [test_jwk]
        cache = described_class.new(mock_connection, project_id, manual_jwks)

        # Check that cache_last_update was set
        expect(cache.instance_variable_get(:@cache_last_update)).to be > 0
      end
    end

    context 'without manual JWKS' do
      it 'does not pre-cache anything' do
        cache = described_class.new(mock_connection, project_id)

        expect(cache.instance_variable_get(:@cached_keys)).to be_nil
        expect(cache.instance_variable_get(:@cache_last_update)).to eq(0)
      end
    end
  end

  describe '#get_jwks' do
    context 'when B2C client' do
      it 'uses the B2C endpoint' do
        cache = described_class.new(mock_connection, project_id, nil, is_b2b_client: false)
        expected_endpoint = "/v1/sessions/jwks/#{project_id}"

        mock_connection.mock_responses[expected_endpoint] = { 'keys' => [test_jwk] }

        result = cache.get_jwks(project_id: project_id)
        expect(result['keys']).to eq([test_jwk])
      end
    end

    context 'when B2B client' do
      it 'uses the B2B endpoint' do
        cache = described_class.new(mock_connection, project_id, nil, is_b2b_client: true)
        expected_endpoint = "/v1/b2b/sessions/jwks/#{project_id}"

        mock_connection.mock_responses[expected_endpoint] = { 'keys' => [test_jwk] }

        result = cache.get_jwks(project_id: project_id)
        expect(result['keys']).to eq([test_jwk])
      end
    end
  end

  describe '#loader' do
    context 'with caching behavior' do
      it 'fetches from API on first call (cache miss)' do
        cache = described_class.new(mock_connection, project_id, nil, is_b2b_client: false)
        expected_endpoint = "/v1/sessions/jwks/#{project_id}"

        mock_connection.mock_responses[expected_endpoint] = { 'keys' => [test_jwk] }

        loader = cache.loader
        result = loader.call({})

        expect(result[:keys]).to eq([test_jwk])
      end

      it 'returns cached keys on subsequent calls (cache hit)' do
        cache = described_class.new(mock_connection, project_id, nil, is_b2b_client: false)
        expected_endpoint = "/v1/sessions/jwks/#{project_id}"

        # Mock API response
        mock_connection.mock_responses[expected_endpoint] = { 'keys' => [test_jwk] }

        loader = cache.loader

        # First call - should hit API
        result1 = loader.call({})

        # Clear mock responses to ensure second call doesn't hit API
        mock_connection.mock_responses = {}

        # Second call - should use cache
        result2 = loader.call({})

        expect(result1[:keys]).to eq([test_jwk])
        expect(result2[:keys]).to eq([test_jwk])
      end

      it 'invalidates cache when requested and expired' do
        cache = described_class.new(mock_connection, project_id, nil, is_b2b_client: false)
        expected_endpoint = "/v1/sessions/jwks/#{project_id}"

        # Mock API responses
        old_jwk = test_jwk
        new_jwk = JWT::JWK.new(OpenSSL::PKey::RSA.new(2048), 'new-key-id').export

        mock_connection.mock_responses[expected_endpoint] = { 'keys' => [old_jwk] }

        loader = cache.loader

        # First call
        result1 = loader.call({})
        expect(result1[:keys]).to eq([old_jwk])

        # Simulate cache expiry by setting old timestamp
        cache.instance_variable_set(:@cache_last_update, Time.now.to_i - 400) # More than 300 seconds ago

        # Update mock response
        mock_connection.mock_responses[expected_endpoint] = { 'keys' => [new_jwk] }

        # Call with invalidate option
        result2 = loader.call({ invalidate: true })
        expect(result2[:keys]).to eq([new_jwk])
      end
    end

    context 'with B2B vs B2C endpoint selection' do
      it 'B2C client calls B2C endpoint' do
        cache = described_class.new(mock_connection, project_id, nil, is_b2b_client: false)
        b2c_endpoint = "/v1/sessions/jwks/#{project_id}"
        b2b_endpoint = "/v1/b2b/sessions/jwks/#{project_id}"

        mock_connection.mock_responses[b2c_endpoint] = { 'keys' => [test_jwk] }
        mock_connection.mock_responses[b2b_endpoint] = { 'keys' => [] } # Should not be called

        loader = cache.loader
        result = loader.call({})

        expect(result[:keys]).to eq([test_jwk])
      end

      it 'B2B client calls B2B endpoint' do
        cache = described_class.new(mock_connection, project_id, nil, is_b2b_client: true)
        b2c_endpoint = "/v1/sessions/jwks/#{project_id}"
        b2b_endpoint = "/v1/b2b/sessions/jwks/#{project_id}"

        mock_connection.mock_responses[b2c_endpoint] = { 'keys' => [] } # Should not be called
        mock_connection.mock_responses[b2b_endpoint] = { 'keys' => [test_jwk] }

        loader = cache.loader
        result = loader.call({})

        expect(result[:keys]).to eq([test_jwk])
      end
    end

    context 'with manual JWKS' do
      it 'does not call the API when manual JWKS are provided and then requested immediately' do
        manual_jwks = [test_jwk]
        cache = described_class.new(mock_connection, project_id, manual_jwks, is_b2b_client: false)

        # Don't set up any mock responses - API should never be called
        mock_connection.mock_responses = {}

        loader = cache.loader
        result = loader.call({})

        expect(result[:keys]).to eq(manual_jwks)
      end

      it 'works for both B2C and B2B with manual JWKS' do
        manual_jwks = [test_jwk]

        # Test B2C
        b2c_cache = described_class.new(mock_connection, project_id, manual_jwks, is_b2b_client: false)
        b2c_result = b2c_cache.loader.call({})
        expect(b2c_result[:keys]).to eq(manual_jwks)

        # Test B2B
        b2b_cache = described_class.new(mock_connection, project_id, manual_jwks, is_b2b_client: true)
        b2b_result = b2b_cache.loader.call({})
        expect(b2b_result[:keys]).to eq(manual_jwks)
      end
    end
  end

  describe 'integration with JWT.decode' do
    it 'provides a loader compatible with JWT.decode' do
      # Create a real JWK for testing
      jwk = JWT::JWK.new(OpenSSL::PKey::RSA.new(2048), 'integration-test-key')
      manual_jwks = [jwk.export]

      cache = described_class.new(mock_connection, project_id, manual_jwks)

      # Create a JWT using the JWK
      claims = {
        'iss' => "stytch.com/#{project_id}",
        'aud' => project_id,
        'sub' => 'user-test-123',
        'exp' => Time.now.to_i + 3600,
        'iat' => Time.now.to_i,
        'nbf' => Time.now.to_i
      }

      token = JWT.encode(claims, jwk.keypair, 'RS256', { kid: jwk.kid })

      # Verify JWT.decode can use our cache loader
      expect do
        JWT.decode(
          token,
          nil,
          true,
          {
            algorithms: ['RS256'],
            jwks: cache.loader,
            iss: "stytch.com/#{project_id}",
            aud: project_id
          }
        )
      end.not_to raise_error
    end
  end
end
