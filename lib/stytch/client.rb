require_relative 'endpoints/user'
require_relative 'endpoints/magic'
require_relative 'endpoints/otp'

module Stytch
  class Client
    include Stytch::Endpoints::User
    include Stytch::Endpoints::Magic
    include Stytch::Endpoints::OTP

    ENVIRONMENTS = %i[live test].freeze

    def initialize(env:, project_id:, secret:, &block)
      @api_host   = api_host(env)
      @project_id  = project_id
      @secret     = secret

      create_connection(&block)
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

    def get(path)
      @connection.get(
          path
      ).body
    end

    def post(path, payload)
      @connection.post(
          path,
          payload
      ).body
    end

    def put(path, payload)
      @connection.put(
          path,
          payload
      ).body
    end

    def delete(path)
      @connection.delete(
          path
      ).body
    end

    def request_with_query_params(path, params)
      request = path
      params.compact.each_with_index do |p, i|
        if i == 0
          request += "?#{p[0].to_s}=#{p[1]}"
        else
          request += "&#{p[0].to_s}=#{p[1]}"
        end
      end
      request
    end
  end
end
