# frozen_string_literal: true

require_relative "request_helper"

module Stytch
  class Debug
    include Stytch::RequestHelper

    def initialize(connection)
      @connection = connection
    end

    def whoami()
      query_params = {}
      request = request_with_query_params("/v1/debug/whoami", query_params)
      get_request(request)
    end
  end
end
