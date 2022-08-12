# frozen_string_literal: true

require 'faraday'
# require 'faraday_middleware'

require_relative '../../lib/stytch/client'
require_relative '../../lib/stytch/middleware'

require 'test/unit'

class TestClient < Test::Unit::TestCase
  def test_production_environments
    _client = Stytch::Client.new(
      env: :test,
      project_id: 'project-test-00000000-0000-0000-0000-000000000000',
      secret: 'secret-test-11111111-1111-1111-1111-111111111111',
    )

    _client = Stytch::Client.new(
      env: :live,
      project_id: 'project-live-00000000-0000-0000-0000-000000000000',
      secret: 'secret-live-11111111-1111-1111-1111-111111111111',
    )
  end

  def test_development_urls
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

  def test_invalid_env
    assert_raises(ArgumentError) do
      _client = Stytch::Client.new(
        env: 'ftp://url',
        project_id: 'project-test-00000000-0000-0000-0000-000000000000',
        secret: 'secret-test-11111111-1111-1111-1111-111111111111',
      )
    end
  end
end
