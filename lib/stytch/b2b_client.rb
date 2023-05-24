# frozen_string_literal: true

require_relative 'b2b_magic_links'
require_relative 'b2b_organizations'
require_relative 'b2b_passwords'
require_relative 'b2b_sessions'
require_relative 'b2b_sso'
require_relative 'debug'

module StytchB2B
  class Client
    ENVIRONMENTS = %i[live test].freeze

    attr_reader :debug, :magic_links, :organizations, :passwords, :sso, :sessions

    def initialize(project_id:, secret:, env: nil, &block)
      @api_host   = api_host(env, project_id)
      @project_id = project_id
      @secret     = secret

      create_connection(&block)

      @debug = Stytch::Debug.new(@connection)
      @magic_links = StytchB2B::MagicLinks.new(@connection)
      @organizations = StytchB2B::Organizations.new(@connection)
      @passwords = StytchB2B::Passwords.new(@connection)
      @sso = StytchB2B::SSO.new(@connection)
      @sessions = StytchB2B::Sessions.new(@connection)
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