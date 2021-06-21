require_relative 'users'
require_relative 'magic_links'
require_relative 'otps'

module Stytch
  class Client
    ENVIRONMENTS = %i[live test].freeze

    def initialize(env:, project_id:, secret:, &block)
      @api_host   = api_host(env)
      @project_id = project_id
      @secret     = secret

      create_connection(&block)
    end

    def users
      Stytch::Users.new(@connection)
    end

    def magic_links
      Stytch::MagicLinks.new(@connection)
    end

    def otps
      Stytch::OTPS.new(@connection)
    end

    private

    def api_host(env)
      if env == :live
        "https://api.stytch.com"
      elsif env == :test
        "https://test.stytch.com"
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
