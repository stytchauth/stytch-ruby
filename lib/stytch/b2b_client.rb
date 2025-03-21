# frozen_string_literal: true

require_relative 'b2b_discovery'
require_relative 'b2b_impersonation'
require_relative 'b2b_magic_links'
require_relative 'b2b_oauth'
require_relative 'b2b_organizations'
require_relative 'b2b_otp'
require_relative 'b2b_passwords'
require_relative 'b2b_rbac'
require_relative 'b2b_recovery_codes'
require_relative 'b2b_scim'
require_relative 'b2b_sessions'
require_relative 'b2b_sso'
require_relative 'b2b_totps'
require_relative 'fraud'
require_relative 'm2m'
require_relative 'project'
require_relative 'rbac_local'

module StytchB2B
  class Client
    ENVIRONMENTS = %i[live test].freeze

    attr_reader :discovery, :fraud, :impersonation, :m2m, :magic_links, :oauth, :otps, :organizations, :passwords, :project, :rbac, :recovery_codes, :scim, :sso, :sessions, :totps

    def initialize(project_id:, secret:, env: nil, fraud_env: nil, &block)
      @api_host = api_host(env, project_id)
      @fraud_api_host = fraud_api_host(fraud_env)
      @project_id = project_id
      @secret = secret
      @is_b2b_client = true

      create_connection(&block)

      rbac = StytchB2B::RBAC.new(@connection)
      @policy_cache = StytchB2B::PolicyCache.new(rbac_client: rbac)

      @discovery = StytchB2B::Discovery.new(@connection)
      @fraud = Stytch::Fraud.new(@fraud_connection)
      @impersonation = StytchB2B::Impersonation.new(@connection)
      @m2m = Stytch::M2M.new(@connection, @project_id, @is_b2b_client)
      @magic_links = StytchB2B::MagicLinks.new(@connection)
      @oauth = StytchB2B::OAuth.new(@connection)
      @otps = StytchB2B::OTPs.new(@connection)
      @organizations = StytchB2B::Organizations.new(@connection)
      @passwords = StytchB2B::Passwords.new(@connection)
      @project = Stytch::Project.new(@connection)
      @rbac = StytchB2B::RBAC.new(@connection)
      @recovery_codes = StytchB2B::RecoveryCodes.new(@connection)
      @scim = StytchB2B::SCIM.new(@connection)
      @sso = StytchB2B::SSO.new(@connection)
      @sessions = StytchB2B::Sessions.new(@connection, @project_id, @policy_cache)
      @totps = StytchB2B::TOTPs.new(@connection)
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
