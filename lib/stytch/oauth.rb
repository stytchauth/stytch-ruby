# frozen_string_literal: true

require_relative 'request_helper'

module Stytch
  class OAuth
    include Stytch::RequestHelper

    PATH = '/v1/oauth'

    def initialize(connection)
      @connection = connection
    end

    def authenticate(
      token:,
      session_management_type:,
    )
      request = {
        token: token
        session_management_type: session_management_type
      }

      post_request("#{PATH}/authenticate", request)
    end
  end
end
