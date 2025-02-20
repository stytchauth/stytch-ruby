# frozen_string_literal: true

require_relative 'crypto_wallets'
require_relative 'fraud'
require_relative 'impersonation'
require_relative 'm2m'
require_relative 'magic_links'
require_relative 'oauth'
require_relative 'otps'
require_relative 'passwords'
require_relative 'project'
require_relative 'sessions'
require_relative 'totps'
require_relative 'users'
require_relative 'webauthn'

module Stytch
  class Client
    ENVIRONMENTS = %i[live test].freeze

    attr_reader :crypto_wallets, :fraud, :impersonation, :m2m, :magic_links, :oauth, :otps, :passwords, :project, :sessions, :totps, :users, :webauthn

    def initialize(project_id:, secret:, env: nil, fraud_env: nil, &block)
      @api_host = api_host(env, project_id)
      @fraud_api_host = fraud_api_host(fraud_env)
      @project_id = project_id
      @secret = secret
      @is_b2b_client = false

      create_connection(&block)

      @crypto_wallets = Stytch::CryptoWallets.new(@connection)
      @fraud = Stytch::Fraud.new(@fraud_connection)
      @impersonation = Stytch::Impersonation.new(@connection)
      @m2m = Stytch::M2M.new(@connection, @project_id, @is_b2b_client)
      @magic_links = Stytch::MagicLinks.new(@connection)
      @oauth = Stytch::OAuth.new(@connection)
      @otps = Stytch::OTPs.new(@connection)
      @passwords = Stytch::Passwords.new(@connection)
      @project = Stytch::Project.new(@connection)
      @sessions = Stytch::Sessions.new(@connection, @project_id)
      @totps = Stytch::TOTPs.new(@connection)
      @users = Stytch::Users.new(@connection)
      @webauthn = Stytch::WebAuthn.new(@connection)
    end

    private

    def api_host(env, project_id)
      case env
      when :live
        'https://api.stytch.com'
      when :test
        'https://test.stytch.com'
      when %r{\Ahttps?://}
        # If this is a string that looks like a URL, assume it's an internal development URL.
        env
      else
        if project_id.start_with? 'project-live-'
          'https://api.stytch.com'
        else
          'https://test.stytch.com'
        end
      end
    end

    def fraud_api_host(fraud_env)
      case fraud_env
      when %r{\Ahttps?://}
        # If this is a string that looks like a URL, assume it's an internal development URL.
        fraud_env
      else
        'https://telemetry.stytch.com'
      end
    end

    def create_connection
      @connection = Faraday.new(url: @api_host) do |builder|
        block_given? ? yield(builder) : build_default_connection(builder)
      end
      @fraud_connection = Faraday.new(url: @fraud_api_host) do |builder|
        block_given? ? yield(builder) : build_default_connection(builder)
      end
      @connection.set_basic_auth(@project_id, @secret)
      @fraud_connection.set_basic_auth(@project_id, @secret)
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
