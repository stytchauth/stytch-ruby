# frozen_string_literal: true

require_relative 'request_helper'

module Stytch
  # JWKSCache handles caching and refreshing of JSON Web Key Sets (JWKS)
  # for JWT signature verification. It can be initialized with pre-cached
  # keys or will fetch them on-demand from the Stytch API.
  class JWKSCache
    include Stytch::RequestHelper

    CACHE_EXPIRY_SECONDS = 300 # 5 minutes

    def initialize(connection, project_id, jwks = nil)
      @connection = connection
      @project_id = project_id
      @cache_last_update = 0

      # If jwks are provided during initialization, use them directly
      return unless jwks

      @cached_keys = { keys: jwks }
      @cache_last_update = Time.now.to_i
    end

    # Returns a lambda suitable for use with JWT.decode
    def loader
      lambda do |options|
        @cached_keys = nil if options[:invalidate] && @cache_last_update < Time.now.to_i - CACHE_EXPIRY_SECONDS
        @cached_keys ||= begin
          @cache_last_update = Time.now.to_i
          keys = []
          get_jwks(project_id: @project_id)['keys'].each do |r|
            keys << r
          end
          { keys: keys }
        end
      end
    end

    # Fetches JWKS from the Stytch API
    def get_jwks(project_id:)
      request_with_query_params(
        @connection,
        '/v1/sessions/jwks/%<project_id>s',
        {
          project_id: project_id
        }
      )
    end
  end
end
