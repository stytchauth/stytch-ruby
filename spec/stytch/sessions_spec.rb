# frozen_string_literal: true

RSpec.describe Stytch::Sessions do
  it 'correctly decodes a JWT' do
    project_id = 'project-test-00000000-0000-0000-0000-000000000000'
    sessions = Stytch::Sessions.new(nil, project_id) # the methods we're calling don't require a connection

    kid = 'jwk-test-00000000-0000-0000-0000-000000000000'
    headers = { kid: kid }

    now = Time.now
    now_timestamp = format_timestamp(now)
    claims = {
      'https://stytch.com/session' => {
        'started_at' => now_timestamp,
        'last_accessed_at' => now_timestamp,
        'expires_at' => (now + 3600).to_datetime.iso8601,
        'attributes' => { 'user_agent' => '', 'ip_address' => '' },
        'authentication_factors' => [
          {
            'delivery_method' => 'email',
            'email_factor' => {
              'email_address' => 'sandbox@stytch.com',
              'email_id' => 'email-live-cca9d7d0-11b6-4167-9385-d7e0c9a77418'
            },
            'last_authenticated_at' => now_timestamp,
            'type' => 'magic_link'
          }
        ],
        'id' => 'session-live-e26a0ccb-0dc0-4edb-a4bb-e70210f43555'
      },
      'sub' => 'user-live-fde03dd1-fff7-4b3c-9b31-ead3fbc224de',
      'iat' => now.to_i,
      'nbf' => now.to_i,
      'exp' => now.to_i + 5 * 60, # five minutes
      'iss' => 'stytch.com/' + project_id,
      'aud' => [project_id]
    }
    jwk = JWT::JWK.new(OpenSSL::PKey::RSA.new(2048), kid)
    token = JWT.encode(claims, jwk.keypair, 'RS256', headers)

    # patch the jwks_loader method so that it uses the JWK we just created
    # instead of calling the API directly
    patch_jwks_loader = lambda do |_options|
      { 'keys' => [jwk.export] }
    end
    sessions.instance_variable_set(:@jwks_loader, patch_jwks_loader)
    expected = sessions.marshal_jwt_into_session(claims)

    expect(sessions.authenticate_jwt_local(token)).to eq(expected)
  end

  it 'marshals JWT into session (new format)' do
    project_id = 'project-test-00000000-0000-0000-0000-000000000000'
    sessions = Stytch::Sessions.new(nil, project_id) # the methods we're calling don't require a connection

    now = Time.utc(2022, 5, 3, 18, 51, 41)
    claims = jwt_claims(project_id, now)

    session = sessions.marshal_jwt_into_session(claims)
    # The session expires an hour after `now`.
    expect(session['session']['expires_at']).to eq('2022-05-03T19:51:41Z')
  end

  it 'marshals JWT into session (old format)' do
    project_id = 'project-test-00000000-0000-0000-0000-000000000000'
    sessions = Stytch::Sessions.new(nil, project_id) # the methods we're calling don't require a connection

    now = Time.utc(2022, 5, 3, 18, 51, 41)
    claims = jwt_claims(project_id, now)
    claims['https://stytch.com/session'].delete('expires_at')

    session = sessions.marshal_jwt_into_session(claims)

    # The "exp" claim is five minutes after `now`.
    expect(session['session']['expires_at']).to eq('2022-05-03T18:56:41Z')
  end

  private

  def jwt_claims(project_id, iat)
    now = iat.to_datetime.iso8601

    {
      'https://stytch.com/session' => {
        'started_at' => now,
        'last_accessed_at' => now,
        'expires_at' => format_timestamp(iat + 3600),
        'attributes' => { 'user_agent' => '', 'ip_address' => '' },
        'authentication_factors' => [
          {
            'delivery_method' => 'email',
            'email_factor' => {
              'email_address' => 'sandbox@stytch.com',
              'email_id' => 'email-live-cca9d7d0-11b6-4167-9385-d7e0c9a77418'
            },
            'last_authenticated_at' => now,
            'type' => 'magic_link'
          }
        ],
        'id' => 'session-live-e26a0ccb-0dc0-4edb-a4bb-e70210f43555'
      },
      'sub' => 'user-live-fde03dd1-fff7-4b3c-9b31-ead3fbc224de',
      'iat' => now.to_time.to_i,
      'nbf' => now.to_time.to_i,
      'exp' => now.to_time.to_i + 5 * 60,  # five minutes
      'iss' => 'stytch.com/' + project_id,
      'aud' => [project_id]
    }
  end

  def format_timestamp(time)
    time.to_datetime.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
  end
end
