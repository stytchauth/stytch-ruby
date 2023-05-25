# frozen_string_literal: true

RSpec.describe Stytch::Client do
  it 'accepts production config' do
    _client = Stytch::Client.new(
      env: :live,
      project_id: 'project-live-00000000-0000-0000-0000-000000000000',
      secret: 'secret-live-11111111-1111-1111-1111-111111111111',
    )
  end

  it 'accepts testing config' do
    _client = Stytch::Client.new(
      env: :test,
      project_id: 'project-test-00000000-0000-0000-0000-000000000000',
      secret: 'secret-test-11111111-1111-1111-1111-111111111111',
    )
  end

  it 'accepts development config' do
    _client = Stytch::Client.new(
      env: 'http://localhost:8000',
      project_id: 'project-test-00000000-0000-0000-0000-000000000000',
      secret: 'secret-test-11111111-1111-1111-1111-111111111111',
    )

    _client = Stytch::Client.new(
      env: 'https://foo.stytch.test',
      project_id: 'project-test-00000000-0000-0000-0000-000000000000',
      secret: 'secret-test-11111111-1111-1111-1111-111111111111',
    )
  end

  it 'infers environment when not given' do
    _client = Stytch::Client.new(
      project_id: 'project-test-00000000-0000-0000-0000-000000000000',
      secret: 'secret-test-11111111-1111-1111-1111-111111111111',
    )
  end
end
