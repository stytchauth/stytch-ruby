# frozen_string_literal: true

require_relative 'request_helper'

module Stytch
  class Users
    include Stytch::RequestHelper

    PATH = '/v1/users'

    def initialize(connection)
      @connection = connection
    end

    def search(query, limit: 100, cursor: nil)
      request = {
        query: query,
        limit: limit
      }
      request[:cursor] = cursor if cursor
      post_request("#{PATH}/search", request)
    end

    def search_all(query, limit: 100)
      Enumerator.new do |enum|
        cursor = nil
        loop do
          resp = search(query, limit: limit, cursor: cursor)
          resp['results'].each do |user|
            enum << user
          end

          cursor = resp['results_metadata']['next_cursor']
          break if cursor.nil?
        end
      end
    end

    def get(user_id:)
      get_request("#{PATH}/#{user_id}")
    end

    def get_pending(
      limit: nil,
      starting_after_id: nil
    )
      query_params = {
        limit: limit,
        starting_after_id: starting_after_id
      }

      request = request_with_query_params("#{PATH}/pending", query_params)

      get_request(request)
    end

    def create(
      email: nil,
      phone_number: nil,
      name: {},
      create_user_as_pending: false,
      attributes: {}
    )
      request = {
        email: email,
        phone_number: phone_number,
        create_user_as_pending: create_user_as_pending
      }

      request[:name] = name if name != {}
      request[:attributes] = attributes if attributes != {}

      post_request(PATH, request)
    end

    def update(
      user_id:,
      name: {},
      emails: [],
      phone_numbers: [],
      crypto_wallets: [],
      attributes: {}
    )
      request = {
        emails: format_emails(emails),
        phone_numbers: format_phone_numbers(phone_numbers),
        crypto_wallets: crypto_wallets
      }

      request[:name] = name if name != {}
      request[:attributes] = attributes if attributes != {}

      put_request("#{PATH}/#{user_id}", request)
    end

    def delete(user_id:)
      delete_request("#{PATH}/#{user_id}")
    end

    def delete_email(
      email_id:
    )
      delete_request("#{PATH}/emails/#{email_id}")
    end

    def delete_phone_number(
      phone_id:
    )
      delete_request("#{PATH}/phone_numbers/#{phone_id}")
    end

    def delete_webauthn_registration(
      webauthn_registration_id:
    )
      delete_request("#{PATH}/webauthn_registrations/#{webauthn_registration_id}")
    end

    def delete_totp(
      totp_id:
    )
      delete_request("#{PATH}/totps/#{totp_id}")
    end

    def delete_crypto_wallet(
      crypto_wallet_id:
    )
      delete_request("#{PATH}/crypto_wallets/#{crypto_wallet_id}")
    end

    def delete_password(
      password_id:
    )
      delete_request("#{PATH}/passwords/#{password_id}")
    end

    def delete_biometric_registration(
      biometric_registration_id:
    )
      delete_request("#{PATH}/biometric_registrations/#{biometric_registration_id}")
    end

    private

    def format_emails(emails)
      e = []
      emails.each { |email| e << { email: email } }
      e
    end

    def format_phone_numbers(phone_numbers)
      p = []
      phone_numbers.each { |phone_number| p << { phone_number: phone_number } }
      p
    end
  end
end
