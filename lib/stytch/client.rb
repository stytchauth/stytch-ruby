# frozen_string_literal: true

require_relative 'users'
require_relative 'magic_links'
require_relative 'oauth'
require_relative 'otps'
require_relative 'sessions'
require_relative 'totps'
require_relative 'webauthn'
require_relative 'crypto_wallets'

module Stytch
  class Client
    ENVIRONMENTS = %i[live test].freeze

    attr_reader :users, :magic_links, :oauth, :otps, :sessions, :totps, :webauthn, :crypto_wallets

    def initialize(env:, project_id:, secret:, &block)
      @api_host   = api_host(env)
      @project_id = project_id
      @secret     = secret

      create_connection(&block)

      @users = Stytch::Users.new(@connection)
      @magic_links = Stytch::MagicLinks.new(@connection)
      @oauth = Stytch::OAuth.new(@connection)
      @otps = Stytch::OTPs.new(@connection)
      @sessions = Stytch::Sessions.new(@connection, @project_id)
      @totps = Stytch::TOTPs.new(@connection)
      @webauthn = Stytch::WebAuthn.new(@connection)
      @crypto_wallets = Stytch::CryptoWallets.new(@connection)
    end

    private

    def api_host(env)
      case env
      when :live
        'https://api.stytch.com'
      when :test
        'https://test.stytch.com'
      else
        raise ArgumentError, "Invalid value for env (#{@env}): should be live or test"
      end
    end

    def create_connection
      @connection = Faraday.new(url: @api_host) do |builder|
        block_given? ? yield(builder) : build_default_connection(builder)
      end
      @connection.basic_auth(@project_id, @secret)
    end

    def build_default_connection(builder)
      builder.options[:timeout] = Stytch::Middleware::NETWORK_TIMEOUT
      builder.headers = Stytch::Middleware::NETWORK_HEADERS
      builder.request :json
      builder.use Stytch::Middleware
      builder.response :json, content_type: /\bjson$/
      builder.adapter Faraday.default_adapter
    end
  end
end
