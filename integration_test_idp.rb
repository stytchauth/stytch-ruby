#!/usr/bin/env ruby
# frozen_string_literal: true

# Integration test script for Stytch::IDP
# Run with: ruby integration_test_idp.rb

require 'bundler/setup'
require 'stytch'
require 'json'

# Configuration
PROJECT_ID = 'project-test-00000000-0000-0000-0000-000000000000'
SECRET_KEY = ENV['STYTCH_SECRET_KEY'] || 'sk_test_...' # Set your secret key
PUBLIC_TOKEN = ENV['STYTCH_PUBLIC_TOKEN'] || 'pk_test_...' # Set your public token

puts "🔐 Stytch IDP Integration Test"
puts "=" * 50
puts "Project ID: #{PROJECT_ID}"
puts "Secret Key: #{SECRET_KEY[0..10]}..." if SECRET_KEY != 'sk_test_...'
puts "Public Token: #{PUBLIC_TOKEN[0..10]}..." if PUBLIC_TOKEN != 'pk_test_...'
puts

# Mock connection for testing
class MockConnection
  def initialize
    @url_prefix = 'https://test.stytch.com'
  end

  def get(path, headers = {})
    # Mock GET request
    puts "  📡 Mock GET request to: #{path}"
    { 'keys' => [] }
  end

  def post(path, data, headers = {})
    # Mock POST request
    puts "  📡 Mock POST request to: #{path}"
    puts "  📦 Data: #{data}"
    { 'active' => true, 'sub' => 'user-test-123', 'scope' => 'read write' }
  end
end

# Mock policy cache for testing
class MockPolicyCache
  def initialize
    @policy = {
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
        },
        {
          'role_id' => 'read',
          'permissions' => [
            {
              'actions' => ['read'],
              'resource_id' => 'users'
            }
          ]
        }
      ]
    }
  end

  def perform_consumer_authorization_check(subject_roles:, authorization_check:)
    puts "🔍 Performing authorization check:"
    puts "  Subject roles: #{subject_roles}"
    puts "  Authorization check: #{authorization_check}"
    
    for role in @policy['roles']
      next unless subject_roles.include?(role['role_id'])

      for permission in role['permissions']
        actions = permission['actions']
        resource = permission['resource_id']
        has_matching_action = actions.include?('*') || actions.include?(authorization_check['action'])
        has_matching_resource = resource == authorization_check['resource_id']
        
        if has_matching_action && has_matching_resource
          puts "  ✅ Authorization granted for role: #{role['role_id']}"
          return
        end
      end
    end

    puts "  ❌ Authorization denied"
    raise Stytch::PermissionError, authorization_check
  end

  def get_policy
    @policy
  end
end

# Initialize IDP with mock connection and policy cache
connection = MockConnection.new
policy_cache = MockPolicyCache.new
idp = Stytch::IDP.new(connection, PROJECT_ID, policy_cache)

puts "✅ IDP initialized with mock policy cache"
puts

# Test 1: Network token introspection (requires real token)
def test_network_introspection(idp)
  puts "🌐 Test 1: Network Token Introspection"
  puts "-" * 40
  
  # This would require a real token from your OAuth2 flow
  puts "Note: This test requires a real access token from OAuth2 flow"
  puts "To test this, you would need to:"
  puts "1. Set up OAuth2 flow with Stytch"
  puts "2. Get an access token"
  puts "3. Use that token in the test below"
  puts
  
  # Example of how to use it (commented out since we don't have a real token)
  # token = "your_real_access_token_here"
  # client_id = "your_client_id"
  # 
  # begin
  #   result = idp.introspect_token_network(
  #     token: token,
  #     client_id: client_id,
  #     authorization_check: {
  #       'action' => 'read',
  #       'resource_id' => 'users'
  #     }
  #   )
  #   puts "✅ Network introspection successful:"
  #   puts JSON.pretty_generate(result)
  # rescue => e
  #   puts "❌ Network introspection failed: #{e.message}"
  # end
end

# Test 2: Local JWT introspection with mock JWT
def test_local_jwt_introspection(idp)
  puts "🔐 Test 2: Local JWT Introspection"
  puts "-" * 40
  
  # Create a mock JWT for testing
  # In a real scenario, this would be a JWT signed by Stytch
  puts "Creating mock JWT for testing..."
  
  # Example JWT structure (this won't be valid, but shows the format)
  mock_claims = {
    'sub' => 'user-test-123',
    'scope' => 'read write',
    'aud' => PROJECT_ID,
    'exp' => Time.now.to_i + 3600,
    'iat' => Time.now.to_i,
    'iss' => "stytch.com/#{PROJECT_ID}",
    'nbf' => Time.now.to_i,
    'custom_field' => 'custom_value'
  }
  
  puts "Mock JWT claims:"
  puts JSON.pretty_generate(mock_claims)
  puts
  
  # Note: This will fail because we don't have a real JWT
  puts "Note: Local JWT introspection requires a real JWT signed by Stytch"
  puts "The mock JWT above shows the expected structure"
  puts
end

# Test 3: Authorization check scenarios
def test_authorization_scenarios(idp)
  puts "🔍 Test 3: Authorization Check Scenarios"
  puts "-" * 40
  
  # Test different authorization scenarios
  scenarios = [
    {
      name: "Admin with wildcard permission",
      roles: ['admin'],
      check: { 'action' => 'any_action', 'resource_id' => 'users' }
    },
    {
      name: "User with specific permission",
      roles: ['user'],
      check: { 'action' => 'read', 'resource_id' => 'users' }
    },
    {
      name: "User with write permission",
      roles: ['user'],
      check: { 'action' => 'write', 'resource_id' => 'posts' }
    },
    {
      name: "Read role with read permission",
      roles: ['read'],
      check: { 'action' => 'read', 'resource_id' => 'users' }
    },
    {
      name: "User without permission (should fail)",
      roles: ['user'],
      check: { 'action' => 'write', 'resource_id' => 'users' }
    },
    {
      name: "Unknown role (should fail)",
      roles: ['unknown'],
      check: { 'action' => 'read', 'resource_id' => 'users' }
    }
  ]
  
  scenarios.each do |scenario|
    puts "Testing: #{scenario[:name]}"
    begin
      policy_cache.perform_consumer_authorization_check(
        subject_roles: scenario[:roles],
        authorization_check: scenario[:check]
      )
      puts "  ✅ Authorization successful"
    rescue Stytch::PermissionError => e
      puts "  ❌ Authorization failed (expected): #{e.message}"
    rescue => e
      puts "  ❌ Unexpected error: #{e.message}"
    end
    puts
  end
end

# Test 4: JWKS endpoint
def test_jwks_endpoint(idp)
  puts "🔑 Test 4: JWKS Endpoint"
  puts "-" * 40
  
  begin
    jwks = idp.get_jwks(project_id: PROJECT_ID)
    puts "✅ JWKS retrieved successfully:"
    puts "  Keys count: #{jwks['keys']&.length || 0}"
    if jwks['keys']&.any?
      puts "  First key ID: #{jwks['keys'].first['kid']}"
    end
  rescue => e
    puts "❌ Failed to retrieve JWKS: #{e.message}"
  end
  puts
end

# Test 5: Error handling
def test_error_handling(idp)
  puts "⚠️  Test 5: Error Handling"
  puts "-" * 40
  
  # Test with invalid JWT
  puts "Testing with invalid JWT..."
  begin
    result = idp.introspect_access_token_local(
      access_token: 'invalid.jwt.token',
      authorization_check: {
        'action' => 'read',
        'resource_id' => 'users'
      }
    )
    puts "  Result: #{result}"
  rescue => e
    puts "  ❌ Expected error: #{e.class} - #{e.message}"
  end
  puts
end

# Run all tests
puts "🚀 Starting Integration Tests..."
puts

test_network_introspection(idp)
test_local_jwt_introspection(idp)
test_authorization_scenarios(idp)
test_jwks_endpoint(idp)
test_error_handling(idp)

puts "🏁 Integration tests completed!"
puts
puts "📝 Next Steps:"
puts "1. Set up OAuth2 flow with Stytch to get real access tokens"
puts "2. Test with real JWTs signed by Stytch"
puts "3. Configure real policy cache with your RBAC rules"
puts "4. Test with your actual client credentials"
puts
puts "💡 Tips:"
puts "- Set STYTCH_SECRET_KEY environment variable for real API calls"
puts "- Use real project ID and tokens for production testing"
puts "- Check Stytch documentation for OAuth2 setup guide" 