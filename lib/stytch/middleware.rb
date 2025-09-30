# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

require_relative 'version'

module Stytch
  class Middleware < ::Faraday::Middleware
    NETWORK_HEADERS = {
      'User-Agent' => "Stytch Ruby v#{Stytch::VERSION}",
      'Content-Type' => 'application/json'
    }.freeze

    NETWORK_TIMEOUT = 31

    def self.timeout(custom_timeout = nil)
      custom_timeout || NETWORK_TIMEOUT
    end
  end
end
