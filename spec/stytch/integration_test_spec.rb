# frozen_string_literal: true

def fake_email
  (0...20).map { rand(65..90).chr }.join + '@example.com'
end

def with_temporary_user(client)
  create_resp = client.users.create(email: fake_email)
  yield create_resp['user']
  client.users.delete(user_id: create_resp['user_id'])
end

RSpec.describe Stytch::Client do
  it 'does the integration test' do
    if ENV['STYTCH_RUBY_RUN_INTEGRATION_TESTS'] != '1'
      skip 'STYTCH_RUBY_RUN_INTEGRATION_TESTS not set' do
      end
    end

    project_id = ENV['STYTCH_PROJECT_ID']
    secret = ENV['STYTCH_SECRET']
    b2c_client = Stytch::Client.new(project_id:, secret:)

    crypto_auth_start = b2c_client.crypto_wallets.authenticate_start(
      crypto_wallet_type: 'ethereum',
      crypto_wallet_address: '0x6df2dB4Fb3DA35d241901Bd53367770BF03123f1'
    )
    expect(crypto_auth_start['status_code']).to eq(200)

    crypto_auth = b2c_client.crypto_wallets.authenticate(
      crypto_wallet_type: 'ethereum',
      crypto_wallet_address: '0x6df2dB4Fb3DA35d241901Bd53367770BF03123f1',
      signature: '0x0c4f82edc3c818b6beff4b89e0682994e5878074609903cecdfb'
    )
    expect(crypto_auth['status_code']).to eq(200)

    magic_links_auth = b2c_client.magic_links.authenticate(
      token: 'DOYoip3rvIMMW5lgItikFK-Ak1CfMsgjuiCyI7uuU94='
    )
    expect(magic_links_auth['status_code']).to eq(200)

    magic_links_create = {}
    with_temporary_user(b2c_client) do |user|
      magic_links_create = b2c_client.magic_links.create(
        user_id: user['user_id']
      )
    end
    expect(magic_links_create['status_code']).to eq(200)

    magic_links_email_invite = b2c_client.magic_links.email.invite(
      email: 'sandbox@stytch.com'
    )
    expect(magic_links_email_invite['status_code']).to eq(200)

    magic_links_email_revoke = b2c_client.magic_links.email.revoke_invite(
      email: 'sandbox@stytch.com'
    )
    expect(magic_links_email_revoke['status_code']).to eq(200)

    magic_links_email_login = b2c_client.magic_links.email.login_or_create(
      email: 'sandbox@stytch.com'
    )
    expect(magic_links_email_login['status_code']).to eq(200)

    magic_links_email_send = b2c_client.magic_links.email.send(
      email: 'sandbox@stytch.com'
    )
    expect(magic_links_email_send['status_code']).to eq(200)

    oauth_attach = {}
    with_temporary_user(b2c_client) do |user|
      oauth_attach = b2c_client.oauth.attach(
        provider: 'google',
        user_id: user['user_id']
      )
    end
    expect(oauth_attach['status_code']).to eq(200)

    oauth_auth = b2c_client.oauth.authenticate(
      token: 'hdPVZHHX0UoRa7hJTuuPHi1vlddffSnoweRbVFf5-H8g'
    )
    expect(oauth_auth['status_code']).to eq(200)

    otp_email_login = b2c_client.otps.email.login_or_create(
      email: 'sandbox@stytch.com'
    )
    expect(otp_email_login['status_code']).to eq(200)

    otp_email_send = b2c_client.otps.email.send(
      email: 'sandbox@stytch.com'
    )
    expect(otp_email_send['status_code']).to eq(200)

    otp_email_auth = b2c_client.otps.authenticate(
      method_id: otp_email_send['email_id'],
      code: '000000'
    )
    expect(otp_email_auth['status_code']).to eq(200)

    otp_sms_login = b2c_client.otps.sms.login_or_create(
      phone_number: '+10000000000'
    )
    expect(otp_sms_login['status_code']).to eq(200)

    otp_sms_send = b2c_client.otps.sms.send(
      phone_number: '+10000000000'
    )
    expect(otp_sms_send['status_code']).to eq(200)

    otp_sms_auth = b2c_client.otps.authenticate(
      method_id: otp_sms_send['phone_id'],
      code: '000000'
    )
    expect(otp_sms_auth['status_code']).to eq(200)

    otp_whatsapp_login = b2c_client.otps.whatsapp.login_or_create(
      phone_number: '+10000000000'
    )
    expect(otp_whatsapp_login['status_code']).to eq(200)

    otp_whatsapp_send = b2c_client.otps.whatsapp.send(
      phone_number: '+10000000000'
    )
    expect(otp_whatsapp_send['status_code']).to eq(200)

    otp_whatsapp_auth = b2c_client.otps.authenticate(
      method_id: otp_whatsapp_send['phone_id'],
      code: '000000'
    )
    expect(otp_whatsapp_auth['status_code']).to eq(200)

    passwords_strength_check = b2c_client.passwords.strength_check(
      password: '_7Hk>%cN0a?kMR]oNWT'
    )
    expect(passwords_strength_check['status_code']).to eq(200)

    pw_email = fake_email
    passwords_create = b2c_client.passwords.create(
      email: pw_email,
      password: '_7Hk>%cN0a?kMR]oNWT'
    )
    expect(passwords_create['status_code']).to eq(200)

    passwords_auth = b2c_client.passwords.authenticate(
      email: pw_email,
      password: '_7Hk>%cN0a?kMR]oNWT'
    )
    expect(passwords_auth['status_code']).to eq(200)

    passwords_existing_reset = b2c_client.passwords.existing_password.reset(
      email: pw_email,
      existing_password: '_7Hk>%cN0a?kMR]oNWT',
      new_password: '_7Hk>%cN0a?kMR]oNWT2'
    )
    expect(passwords_existing_reset['status_code']).to eq(200)

    passwords_user_deletion = b2c_client.users.delete(
      user_id: passwords_create['user_id']
    )
    expect(passwords_user_deletion['status_code']).to eq(200)

    sessions_get = {}
    with_temporary_user(b2c_client) do |user|
      sessions_get = b2c_client.sessions.get(
        user_id: user['user_id']
      )
    end
    expect(sessions_get['status_code']).to eq(200)

    sessions_auth = b2c_client.sessions.authenticate(
      session_token: 'WJtR5BCy38Szd5AfoDpf0iqFKEt4EE5JhjlWUY7l3FtY'
    )
    expect(sessions_auth['status_code']).to eq(200)

    totps_create = b2c_client.totps.create(
      user_id: 'user-test-e3795c81-f849-4167-bfda-e4a6e9c280fd'
    )
    expect(totps_create['status_code']).to eq(200)

    totps_auth = b2c_client.totps.authenticate(
      user_id: 'user-test-e3795c81-f849-4167-bfda-e4a6e9c280fd',
      totp_code: '000000'
    )
    expect(totps_auth['status_code']).to eq(200)

    totps_recovery_codes = b2c_client.totps.recovery_codes(
      user_id: 'user-test-e3795c81-f849-4167-bfda-e4a6e9c280fd'
    )
    expect(totps_recovery_codes['status_code']).to eq(200)

    totps_recover = b2c_client.totps.recover(
      user_id: 'user-test-e3795c81-f849-4167-bfda-e4a6e9c280fd',
      recovery_code: 'a1b2-c3d4-e5f6'
    )
    expect(totps_recover['status_code']).to eq(200)

    users_email = fake_email
    users_create = b2c_client.users.create(
      email: users_email
    )
    expect(users_create['status_code']).to eq(201)

    users_search = b2c_client.users.search(
      limit: 1
    )
    expect(users_search['status_code']).to eq(200)

    users_get = b2c_client.users.get(
      user_id: users_create['user_id']
    )
    expect(users_get['status_code']).to eq(200)

    users_delete = b2c_client.users.delete(
      user_id: users_create['user_id']
    )
    expect(users_delete['status_code']).to eq(200)
  end
end
