# B2B IDP (Identity Provider) Class

The `StytchB2B::IDP` class provides functionality to introspect OAuth2 tokens in a B2B (Business-to-Business) context. This class allows you to validate and extract information from access tokens and refresh tokens.

## Features

- **Network Token Introspection**: Introspect tokens by calling the Stytch API
- **Local Token Introspection**: Validate JWT tokens locally without API calls
- **Authorization Checks**: Perform RBAC (Role-Based Access Control) authorization checks
- **Custom Claims Support**: Extract and handle custom claims from tokens

## Usage

### Basic Setup

```ruby
require 'stytch'

# Initialize the B2B client
client = StytchB2B::Client.new(
  project_id: 'project-test-00000000-0000-0000-0000-000000000000',
  secret: 'your-secret-key'
)

# Access the IDP instance
idp = client.idp
```

### Network Token Introspection

Introspect a token by calling the Stytch API:

```ruby
# Introspect an access token
result = idp.introspect_token_network(
  token: 'your-access-token',
  client_id: 'your-client-id',
  client_secret: 'your-client-secret', # optional
  token_type_hint: 'access_token' # or 'refresh_token'
)

if result
  puts "Token is valid"
  puts "Subject: #{result['subject']}"
  puts "Scope: #{result['scope']}"
  puts "Organization: #{result['organization_claim']['organization_id']}"
  puts "Custom claims: #{result['custom_claims']}"
else
  puts "Token is invalid or inactive"
end
```

### Local Token Introspection

Validate a JWT token locally without making API calls:

```ruby
# Introspect an access token locally
result = idp.introspect_access_token_local(
  access_token: 'your-jwt-access-token'
)

if result
  puts "JWT is valid"
  puts "Subject: #{result['subject']}"
  puts "Scope: #{result['scope']}"
  puts "Organization: #{result['organization_claim']['organization_id']}"
  puts "Custom claims: #{result['custom_claims']}"
else
  puts "JWT is invalid"
end
```

### Authorization Checks

Perform RBAC authorization checks with tokens:

```ruby
# Define an authorization check
authorization_check = {
  'action' => 'read',
  'resource_id' => 'users',
  'organization_id' => 'org-123'
}

# Introspect with authorization check
result = idp.introspect_token_network(
  token: 'your-access-token',
  client_id: 'your-client-id',
  authorization_check: authorization_check
)

# If the authorization check fails, a PermissionError or TenancyError will be raised
```

### Error Handling

The IDP class can raise various exceptions:

```ruby
begin
  result = idp.introspect_access_token_local(
    access_token: 'invalid-token'
  )
rescue Stytch::JWTInvalidIssuerError
  puts "Invalid JWT issuer"
rescue Stytch::JWTInvalidAudienceError
  puts "Invalid JWT audience"
rescue Stytch::JWTExpiredSignatureError
  puts "JWT has expired"
rescue Stytch::JWTIncorrectAlgorithmError
  puts "Incorrect JWT algorithm"
rescue Stytch::PermissionError => e
  puts "Permission denied: #{e.message}"
rescue Stytch::TenancyError => e
  puts "Tenancy error: #{e.message}"
end
```

## Return Values

Both introspection methods return a hash with the following structure when successful:

```ruby
{
  'subject' => 'user-123',
  'scope' => 'read write',
  'audience' => 'your-audience',
  'expires_at' => 1234567890,
  'issued_at' => 1234567890,
  'issuer' => 'stytch.com/your-project-id',
  'not_before' => 1234567890,
  'token_type' => 'access_token',
  'custom_claims' => { 'custom_field' => 'custom_value' },
  'organization_claim' => { 'organization_id' => 'org-123' }
}
```

## Differences from Python Implementation

The Ruby implementation follows the same patterns as the Python version but with Ruby-specific conventions:

- Uses keyword arguments for method parameters
- Returns `nil` instead of `None` for invalid tokens
- Uses Ruby naming conventions (snake_case)
- Integrates with the existing Ruby SDK architecture

## Integration with B2B Client

The IDP class is automatically available when you initialize a `StytchB2B::Client`:

```ruby
client = StytchB2B::Client.new(
  project_id: 'your-project-id',
  secret: 'your-secret'
)

# Access IDP functionality
idp = client.idp
```

This integration ensures that the IDP class has access to the same connection, project configuration, and policy cache as other B2B services. 