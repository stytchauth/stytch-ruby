# frozen_string_literal: true

require_relative 'request_helper'

module Stytch
  class CryptoWallets
    include Stytch::RequestHelper

    PATH = '/v1/crypto_wallets'

    def initialize(connection)
      @connection = connection
    end

    def authenticate_start(
      crypto_wallet_address:,
      crypto_wallet_type:,
      user_id: nil
    )
      request = {
        crypto_wallet_address: crypto_wallet_address,
        crypto_wallet_type: crypto_wallet_type
      }

      request[:user_id] = user_id unless user_id.nil?

      post_request("#{PATH}/authenticate/start", request)
    end

    def authenticate(
      crypto_wallet_address:,
      crypto_wallet_type:,
      signature:,
      session_token: nil,
      session_duration_minutes: nil
    )
      request = {
        crypto_wallet_address: crypto_wallet_address,
        crypto_wallet_type: crypto_wallet_type,
        signature: signature
      }

      request[:session_token] = session_token unless session_token.nil?
      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?

      post_request("#{PATH}/authenticate", request)
    end
  end
end
