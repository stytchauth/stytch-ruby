# frozen_string_literal: true

# !!!
# WARNING: This file is autogenerated
# Only modify code within MANUAL() sections
# or your changes may be overwritten later!
# !!!

require_relative 'request_helper'

module Stytch
  class OTPs
    include Stytch::RequestHelper
    attr_reader :sms, :whatsapp, :email

    def initialize(connection)
      @connection = connection

      @sms = Stytch::OTPs::Sms.new(@connection)
      @whatsapp = Stytch::OTPs::Whatsapp.new(@connection)
      @email = Stytch::OTPs::Email.new(@connection)
    end

    # Authenticate a User given a `method_id` (the associated `email_id` or `phone_id`) and a `code`. This endpoint verifies that the code is valid, hasn't expired or been previously used, and any optional security settings such as IP match or user agent match are satisfied. A given `method_id` may only have a single active OTP code at any given time, if a User requests another OTP code before the first one has expired, the first one will be invalidated.
    #
    # == Parameters:
    # method_id::
    #   The `email_id` or `phone_id` involved in the given authentication.
    #   The type of this field is +String+.
    # code::
    #   The code to authenticate.
    #   The type of this field is +String+.
    # attributes::
    #   Provided attributes to help with fraud detection. These values are pulled and passed into Stytch endpoints by your application.
    #   The type of this field is nilable +Attributes+ (+object+).
    # options::
    #   Specify optional security settings.
    #   The type of this field is nilable +Options+ (+object+).
    # session_token::
    #   The `session_token` associated with a User's existing Session.
    #   The type of this field is nilable +String+.
    # session_duration_minutes::
    #   Set the session lifetime to be this many minutes from now. This will start a new session if one doesn't already exist,
    #   returning both an opaque `session_token` and `session_jwt` for this session. Remember that the `session_jwt` will have a fixed lifetime of
    #   five minutes regardless of the underlying session duration, and will need to be refreshed over time.
    #
    #   This value must be a minimum of 5 and a maximum of 527040 minutes (366 days).
    #
    #   If a `session_token` or `session_jwt` is provided then a successful authentication will continue to extend the session this many minutes.
    #
    #   If the `session_duration_minutes` parameter is not specified, a Stytch session will not be created.
    #   The type of this field is nilable +Integer+.
    # session_jwt::
    #   The `session_jwt` associated with a User's existing Session.
    #   The type of this field is nilable +String+.
    # session_custom_claims::
    #   Add a custom claims map to the Session being authenticated. Claims are only created if a Session is initialized by providing a value in `session_duration_minutes`. Claims will be included on the Session object and in the JWT. To update a key in an existing Session, supply a new value. To delete a key, supply a null value.
    #
    #   Custom claims made with reserved claims ("iss", "sub", "aud", "exp", "nbf", "iat", "jti") will be ignored. Total custom claims size cannot exceed four kilobytes.
    #   The type of this field is nilable +object+.
    #
    # == Returns:
    # An object with the following fields:
    # request_id::
    #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
    #   The type of this field is +String+.
    # user_id::
    #   The unique ID of the affected User.
    #   The type of this field is +String+.
    # method_id::
    #   The `email_id` or `phone_id` involved in the given authentication.
    #   The type of this field is +String+.
    # session_token::
    #   A secret token for a given Stytch Session.
    #   The type of this field is +String+.
    # session_jwt::
    #   The JSON Web Token (JWT) for a given Stytch Session.
    #   The type of this field is +String+.
    # user::
    #   The `user` object affected by this API call. See the [Get user endpoint](https://stytch.com/docs/api/get-user) for complete response field details.
    #   The type of this field is +User+ (+object+).
    # reset_sessions::
    #   Indicates if all other of the User's Sessions need to be reset. You should check this field if you aren't using Stytch's Session product. If you are using Stytch's Session product, we revoke the User's other sessions for you.
    #   The type of this field is +Boolean+.
    # status_code::
    #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
    #   The type of this field is +Integer+.
    # session::
    #   If you initiate a Session, by including `session_duration_minutes` in your authenticate call, you'll receive a full Session object in the response.
    #
    #   See [Session object](https://stytch.com/docs/api/session-object) for complete response fields.
    #
    #   The type of this field is nilable +Session+ (+object+).
    def authenticate(
      method_id:,
      code:,
      attributes: nil,
      options: nil,
      session_token: nil,
      session_duration_minutes: nil,
      session_jwt: nil,
      session_custom_claims: nil
    )
      headers = {}
      request = {
        method_id: method_id,
        code: code
      }
      request[:attributes] = attributes unless attributes.nil?
      request[:options] = options unless options.nil?
      request[:session_token] = session_token unless session_token.nil?
      request[:session_duration_minutes] = session_duration_minutes unless session_duration_minutes.nil?
      request[:session_jwt] = session_jwt unless session_jwt.nil?
      request[:session_custom_claims] = session_custom_claims unless session_custom_claims.nil?

      post_request('/v1/otps/authenticate', request, headers)
    end

    class Sms
      include Stytch::RequestHelper

      def initialize(connection)
        @connection = connection
      end

      # Send a one-time passcode (OTP) to a user's phone number. If you'd like to create a user and send them a passcode with one request, use our [log in or create](https://stytch.com/docs/api/log-in-or-create-user-by-sms) endpoint.
      #
      # Note that sending another OTP code before the first has expired will invalidate the first code.
      #
      # ### Cost to send SMS OTP
      # Before configuring SMS or WhatsApp OTPs, please review how Stytch [bills the costs of international OTPs](https://stytch.com/pricing) and understand how to protect your app against [toll fraud](https://stytch.com/docs/guides/passcodes/toll-fraud/overview).
      #
      # __Note:__ SMS to phone numbers outside of the US and Canada is disabled by default for customers who did not use SMS prior to October 2023. If you're interested in sending international SMS, please reach out to [support@stytch.com](mailto:support@stytch.com?subject=Enable%20international%20SMS).
      #
      # Even when international SMS is enabled, we do not support sending SMS to countries on our [Unsupported countries list](https://stytch.com/docs/guides/passcodes/unsupported-countries).
      #
      # ### Add a phone number to an existing user
      #
      # This endpoint also allows you to add a new phone number to an existing Stytch User. Including a `user_id`, `session_token`, or `session_jwt` in your Send one-time passcode by SMS request will add the new, unverified phone number to the existing Stytch User. If the user successfully authenticates within 5 minutes, the new phone number will be marked as verified and remain permanently on the existing Stytch User. Otherwise, it will be removed from the User object, and any subsequent login requests using that phone number will create a new User.
      #
      # ### Next steps
      #
      # Collect the OTP which was delivered to the user. Call [Authenticate OTP](https://stytch.com/docs/api/authenticate-otp) using the OTP `code` along with the `phone_id` found in the response as the `method_id`.
      #
      # == Parameters:
      # phone_number::
      #   The phone number to use for one-time passcodes. The phone number should be in E.164 format (i.e. +1XXXXXXXXXX). You may use +10000000000 to test this endpoint, see [Testing](https://stytch.com/docs/home#resources_testing) for more detail.
      #   The type of this field is +String+.
      # expiration_minutes::
      #   Set the expiration for the one-time passcode, in minutes. The minimum expiration is 1 minute and the maximum is 10 minutes. The default expiration is 2 minutes.
      #   The type of this field is nilable +Integer+.
      # attributes::
      #   Provided attributes to help with fraud detection. These values are pulled and passed into Stytch endpoints by your application.
      #   The type of this field is nilable +Attributes+ (+object+).
      # locale::
      #   Used to determine which language to use when sending the user this delivery method. Parameter is a [IETF BCP 47 language tag](https://www.w3.org/International/articles/language-tags/), e.g. `"en"`.
      #
      # Currently supported languages are English (`"en"`), Spanish (`"es"`), French (`"fr"`) and Brazilian Portuguese (`"pt-br"`); if no value is provided, the copy defaults to English.
      #
      # Request support for additional languages [here](https://docs.google.com/forms/d/e/1FAIpQLScZSpAu_m2AmLXRT3F3kap-s_mcV6UTBitYn6CdyWP0-o7YjQ/viewform?usp=sf_link")!
      #
      #   The type of this field is nilable +SendRequestLocale+ (string enum).
      # user_id::
      #   The unique ID of a specific User. You may use an `external_id` here if one is set for the user.
      #   The type of this field is nilable +String+.
      # session_token::
      #   The `session_token` associated with a User's existing Session.
      #   The type of this field is nilable +String+.
      # session_jwt::
      #   The `session_jwt` associated with a User's existing Session.
      #   The type of this field is nilable +String+.
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # user_id::
      #   The unique ID of the affected User.
      #   The type of this field is +String+.
      # phone_id::
      #   The unique ID for the phone number.
      #   The type of this field is +String+.
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      def send(
        phone_number:,
        expiration_minutes: nil,
        attributes: nil,
        locale: nil,
        user_id: nil,
        session_token: nil,
        session_jwt: nil
      )
        headers = {}
        request = {
          phone_number: phone_number
        }
        request[:expiration_minutes] = expiration_minutes unless expiration_minutes.nil?
        request[:attributes] = attributes unless attributes.nil?
        request[:locale] = locale unless locale.nil?
        request[:user_id] = user_id unless user_id.nil?
        request[:session_token] = session_token unless session_token.nil?
        request[:session_jwt] = session_jwt unless session_jwt.nil?

        post_request('/v1/otps/sms/send', request, headers)
      end

      # Send a One-Time Passcode (OTP) to a User using their phone number. If the phone number is not associated with a user already, a user will be created.
      #
      # ### Cost to send SMS OTP
      # Before configuring SMS or WhatsApp OTPs, please review how Stytch [bills the costs of international OTPs](https://stytch.com/pricing) and understand how to protect your app against [toll fraud](https://stytch.com/docs/guides/passcodes/toll-fraud/overview).
      #
      # __Note:__ SMS to phone numbers outside of the US and Canada is disabled by default for customers who did not use SMS prior to October 2023. If you're interested in sending international SMS, please reach out to [support@stytch.com](mailto:support@stytch.com?subject=Enable%20international%20SMS).
      #
      # Even when international SMS is enabled, we do not support sending SMS to countries on our [Unsupported countries list](https://stytch.com/docs/guides/passcodes/unsupported-countries).
      #
      # ### Next steps
      #
      # Collect the OTP which was delivered to the User. Call [Authenticate OTP](https://stytch.com/docs/api/authenticate-otp) using the OTP `code` along with the `phone_id` found in the response as the `method_id`.
      #
      # == Parameters:
      # phone_number::
      #   The phone number to use for one-time passcodes. The phone number should be in E.164 format (i.e. +1XXXXXXXXXX). You may use +10000000000 to test this endpoint, see [Testing](https://stytch.com/docs/home#resources_testing) for more detail.
      #   The type of this field is +String+.
      # expiration_minutes::
      #   Set the expiration for the one-time passcode, in minutes. The minimum expiration is 1 minute and the maximum is 10 minutes. The default expiration is 2 minutes.
      #   The type of this field is nilable +Integer+.
      # attributes::
      #   Provided attributes to help with fraud detection. These values are pulled and passed into Stytch endpoints by your application.
      #   The type of this field is nilable +Attributes+ (+object+).
      # create_user_as_pending::
      #   Flag for whether or not to save a user as pending vs active in Stytch. Defaults to false.
      #         If true, users will be saved with status pending in Stytch's backend until authenticated.
      #         If false, users will be created as active. An example usage of
      #         a true flag would be to require users to verify their phone by entering the OTP code before creating
      #         an account for them.
      #   The type of this field is nilable +Boolean+.
      # locale::
      #   Used to determine which language to use when sending the user this delivery method. Parameter is a [IETF BCP 47 language tag](https://www.w3.org/International/articles/language-tags/), e.g. `"en"`.
      #
      # Currently supported languages are English (`"en"`), Spanish (`"es"`), French (`"fr"`) and Brazilian Portuguese (`"pt-br"`); if no value is provided, the copy defaults to English.
      #
      # Request support for additional languages [here](https://docs.google.com/forms/d/e/1FAIpQLScZSpAu_m2AmLXRT3F3kap-s_mcV6UTBitYn6CdyWP0-o7YjQ/viewform?usp=sf_link")!
      #
      #   The type of this field is nilable +LoginOrCreateRequestLocale+ (string enum).
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # user_id::
      #   The unique ID of the affected User.
      #   The type of this field is +String+.
      # phone_id::
      #   The unique ID for the phone number.
      #   The type of this field is +String+.
      # user_created::
      #   In `login_or_create` endpoints, this field indicates whether or not a User was just created.
      #   The type of this field is +Boolean+.
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      def login_or_create(
        phone_number:,
        expiration_minutes: nil,
        attributes: nil,
        create_user_as_pending: nil,
        locale: nil
      )
        headers = {}
        request = {
          phone_number: phone_number
        }
        request[:expiration_minutes] = expiration_minutes unless expiration_minutes.nil?
        request[:attributes] = attributes unless attributes.nil?
        request[:create_user_as_pending] = create_user_as_pending unless create_user_as_pending.nil?
        request[:locale] = locale unless locale.nil?

        post_request('/v1/otps/sms/login_or_create', request, headers)
      end
    end

    class Whatsapp
      include Stytch::RequestHelper

      def initialize(connection)
        @connection = connection
      end

      # Send a One-Time Passcode (OTP) to a User's WhatsApp. If you'd like to create a user and send them a passcode with one request, use our [log in or create](https://stytch.com/docs/api/whatsapp-login-or-create) endpoint.
      #
      # Note that sending another OTP code before the first has expired will invalidate the first code.
      #
      # ### Cost to send SMS OTP
      # Before configuring SMS or WhatsApp OTPs, please review how Stytch [bills the costs of international OTPs](https://stytch.com/pricing) and understand how to protect your app against [toll fraud](https://stytch.com/docs/guides/passcodes/toll-fraud/overview).
      #
      # ### Add a phone number to an existing user
      #
      # This endpoint also allows you to add a new phone number to an existing Stytch User. Including a `user_id`, `session_token`, or `session_jwt` in your Send one-time passcode by WhatsApp request will add the new, unverified phone number to the existing Stytch User. If the user successfully authenticates within 5 minutes, the new phone number will be marked as verified and remain permanently on the existing Stytch User. Otherwise, it will be removed from the User object, and any subsequent login requests using that phone number will create a new User.
      #
      # ### Next steps
      #
      # Collect the OTP which was delivered to the user. Call [Authenticate OTP](https://stytch.com/docs/api/authenticate-otp) using the OTP `code` along with the `phone_id` found in the response as the `method_id`.
      #
      # == Parameters:
      # phone_number::
      #   The phone number to use for one-time passcodes. The phone number should be in E.164 format (i.e. +1XXXXXXXXXX). You may use +10000000000 to test this endpoint, see [Testing](https://stytch.com/docs/home#resources_testing) for more detail.
      #   The type of this field is +String+.
      # expiration_minutes::
      #   Set the expiration for the one-time passcode, in minutes. The minimum expiration is 1 minute and the maximum is 10 minutes. The default expiration is 2 minutes.
      #   The type of this field is nilable +Integer+.
      # attributes::
      #   Provided attributes to help with fraud detection. These values are pulled and passed into Stytch endpoints by your application.
      #   The type of this field is nilable +Attributes+ (+object+).
      # locale::
      #   Used to determine which language to use when sending the user this delivery method. Parameter is a [IETF BCP 47 language tag](https://www.w3.org/International/articles/language-tags/), e.g. `"en"`.
      #
      # Currently supported languages are English (`"en"`), Spanish (`"es"`), French (`"fr"`) and Brazilian Portuguese (`"pt-br"`); if no value is provided, the copy defaults to English.
      #
      # Request support for additional languages [here](https://docs.google.com/forms/d/e/1FAIpQLScZSpAu_m2AmLXRT3F3kap-s_mcV6UTBitYn6CdyWP0-o7YjQ/viewform?usp=sf_link")!
      #
      #   The type of this field is nilable +SendRequestLocale+ (string enum).
      # user_id::
      #   The unique ID of a specific User. You may use an `external_id` here if one is set for the user.
      #   The type of this field is nilable +String+.
      # session_token::
      #   The `session_token` associated with a User's existing Session.
      #   The type of this field is nilable +String+.
      # session_jwt::
      #   The `session_jwt` associated with a User's existing Session.
      #   The type of this field is nilable +String+.
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # user_id::
      #   The unique ID of the affected User.
      #   The type of this field is +String+.
      # phone_id::
      #   The unique ID for the phone number.
      #   The type of this field is +String+.
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      def send(
        phone_number:,
        expiration_minutes: nil,
        attributes: nil,
        locale: nil,
        user_id: nil,
        session_token: nil,
        session_jwt: nil
      )
        headers = {}
        request = {
          phone_number: phone_number
        }
        request[:expiration_minutes] = expiration_minutes unless expiration_minutes.nil?
        request[:attributes] = attributes unless attributes.nil?
        request[:locale] = locale unless locale.nil?
        request[:user_id] = user_id unless user_id.nil?
        request[:session_token] = session_token unless session_token.nil?
        request[:session_jwt] = session_jwt unless session_jwt.nil?

        post_request('/v1/otps/whatsapp/send', request, headers)
      end

      # Send a one-time passcode (OTP) to a User's WhatsApp using their phone number. If the phone number is not associated with a User already, a User will be created.
      #
      # ### Cost to send SMS OTP
      # Before configuring SMS or WhatsApp OTPs, please review how Stytch [bills the costs of international OTPs](https://stytch.com/pricing) and understand how to protect your app against [toll fraud](https://stytch.com/docs/guides/passcodes/toll-fraud/overview).
      #
      # ### Next steps
      #
      # Collect the OTP which was delivered to the User. Call [Authenticate OTP](https://stytch.com/docs/api/authenticate-otp) using the OTP `code` along with the `phone_id` found in the response as the `method_id`.
      #
      # == Parameters:
      # phone_number::
      #   The phone number to use for one-time passcodes. The phone number should be in E.164 format (i.e. +1XXXXXXXXXX). You may use +10000000000 to test this endpoint, see [Testing](https://stytch.com/docs/home#resources_testing) for more detail.
      #   The type of this field is +String+.
      # expiration_minutes::
      #   Set the expiration for the one-time passcode, in minutes. The minimum expiration is 1 minute and the maximum is 10 minutes. The default expiration is 2 minutes.
      #   The type of this field is nilable +Integer+.
      # attributes::
      #   Provided attributes to help with fraud detection. These values are pulled and passed into Stytch endpoints by your application.
      #   The type of this field is nilable +Attributes+ (+object+).
      # create_user_as_pending::
      #   Flag for whether or not to save a user as pending vs active in Stytch. Defaults to false.
      #         If true, users will be saved with status pending in Stytch's backend until authenticated.
      #         If false, users will be created as active. An example usage of
      #         a true flag would be to require users to verify their phone by entering the OTP code before creating
      #         an account for them.
      #   The type of this field is nilable +Boolean+.
      # locale::
      #   Used to determine which language to use when sending the user this delivery method. Parameter is a [IETF BCP 47 language tag](https://www.w3.org/International/articles/language-tags/), e.g. `"en"`.
      #
      # Currently supported languages are English (`"en"`), Spanish (`"es"`), French (`"fr"`) and Brazilian Portuguese (`"pt-br"`); if no value is provided, the copy defaults to English.
      #
      # Request support for additional languages [here](https://docs.google.com/forms/d/e/1FAIpQLScZSpAu_m2AmLXRT3F3kap-s_mcV6UTBitYn6CdyWP0-o7YjQ/viewform?usp=sf_link")!
      #
      #   The type of this field is nilable +LoginOrCreateRequestLocale+ (string enum).
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # user_id::
      #   The unique ID of the affected User.
      #   The type of this field is +String+.
      # phone_id::
      #   The unique ID for the phone number.
      #   The type of this field is +String+.
      # user_created::
      #   In `login_or_create` endpoints, this field indicates whether or not a User was just created.
      #   The type of this field is +Boolean+.
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      def login_or_create(
        phone_number:,
        expiration_minutes: nil,
        attributes: nil,
        create_user_as_pending: nil,
        locale: nil
      )
        headers = {}
        request = {
          phone_number: phone_number
        }
        request[:expiration_minutes] = expiration_minutes unless expiration_minutes.nil?
        request[:attributes] = attributes unless attributes.nil?
        request[:create_user_as_pending] = create_user_as_pending unless create_user_as_pending.nil?
        request[:locale] = locale unless locale.nil?

        post_request('/v1/otps/whatsapp/login_or_create', request, headers)
      end
    end

    class Email
      include Stytch::RequestHelper

      def initialize(connection)
        @connection = connection
      end

      # Send a One-Time Passcode (OTP) to a User using their email. If you'd like to create a user and send them a passcode with one request, use our [log in or create endpoint](https://stytch.com/docs/api/log-in-or-create-user-by-email-otp).
      #
      # ### Add an email to an existing user
      # This endpoint also allows you to add a new email address to an existing Stytch User. Including a `user_id`, `session_token`, or `session_jwt` in your Send one-time passcode by email request will add the new, unverified email address to the existing Stytch User. If the user successfully authenticates within 5 minutes, the new email address will be marked as verified and remain permanently on the existing Stytch User. Otherwise, it will be removed from the User object, and any subsequent login requests using that email address will create a new User.
      #
      # ### Next steps
      # Collect the OTP which was delivered to the user. Call [Authenticate OTP](https://stytch.com/docs/api/authenticate-otp) using the OTP `code` along with the `email_id` found in the response as the `method_id`.
      #
      # == Parameters:
      # email::
      #   The email address of the user to send the one-time passcode to. You may use sandbox@stytch.com to test this endpoint, see [Testing](https://stytch.com/docs/home#resources_testing) for more detail.
      #   The type of this field is +String+.
      # expiration_minutes::
      #   Set the expiration for the one-time passcode, in minutes. The minimum expiration is 1 minute and the maximum is 10 minutes. The default expiration is 2 minutes.
      #   The type of this field is nilable +Integer+.
      # attributes::
      #   Provided attributes to help with fraud detection. These values are pulled and passed into Stytch endpoints by your application.
      #   The type of this field is nilable +Attributes+ (+object+).
      # locale::
      #   Used to determine which language to use when sending the user this delivery method. Parameter is a [IETF BCP 47 language tag](https://www.w3.org/International/articles/language-tags/), e.g. `"en"`.
      #
      # Currently supported languages are English (`"en"`), Spanish (`"es"`), French (`"fr"`) and Brazilian Portuguese (`"pt-br"`); if no value is provided, the copy defaults to English.
      #
      # Request support for additional languages [here](https://docs.google.com/forms/d/e/1FAIpQLScZSpAu_m2AmLXRT3F3kap-s_mcV6UTBitYn6CdyWP0-o7YjQ/viewform?usp=sf_link")!
      #
      #   The type of this field is nilable +SendRequestLocale+ (string enum).
      # user_id::
      #   The unique ID of a specific User. You may use an `external_id` here if one is set for the user.
      #   The type of this field is nilable +String+.
      # session_token::
      #   The `session_token` associated with a User's existing Session.
      #   The type of this field is nilable +String+.
      # session_jwt::
      #   The `session_jwt` associated with a User's existing Session.
      #   The type of this field is nilable +String+.
      # login_template_id::
      #   Use a custom template for login emails. By default, it will use your default email template. The template must be a template using our built-in customizations or a custom HTML email for OTP - Login.
      #   The type of this field is nilable +String+.
      # signup_template_id::
      #   Use a custom template for sign-up emails. By default, it will use your default email template. The template must be a template using our built-in customizations or a custom HTML email for OTP - Sign-up.
      #   The type of this field is nilable +String+.
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # user_id::
      #   The unique ID of the affected User.
      #   The type of this field is +String+.
      # email_id::
      #   The unique ID of a specific email address.
      #   The type of this field is +String+.
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      def send(
        email:,
        expiration_minutes: nil,
        attributes: nil,
        locale: nil,
        user_id: nil,
        session_token: nil,
        session_jwt: nil,
        login_template_id: nil,
        signup_template_id: nil
      )
        headers = {}
        request = {
          email: email
        }
        request[:expiration_minutes] = expiration_minutes unless expiration_minutes.nil?
        request[:attributes] = attributes unless attributes.nil?
        request[:locale] = locale unless locale.nil?
        request[:user_id] = user_id unless user_id.nil?
        request[:session_token] = session_token unless session_token.nil?
        request[:session_jwt] = session_jwt unless session_jwt.nil?
        request[:login_template_id] = login_template_id unless login_template_id.nil?
        request[:signup_template_id] = signup_template_id unless signup_template_id.nil?

        post_request('/v1/otps/email/send', request, headers)
      end

      # Send a one-time passcode (OTP) to a User using their email. If the email is not associated with a User already, a User will be created.
      #
      # ### Next steps
      #
      # Collect the OTP which was delivered to the User. Call [Authenticate OTP](https://stytch.com/docs/api/authenticate-otp) using the OTP `code` along with the `phone_id` found in the response as the `method_id`.
      #
      # == Parameters:
      # email::
      #   The email address of the user to send the one-time passcode to. You may use sandbox@stytch.com to test this endpoint, see [Testing](https://stytch.com/docs/home#resources_testing) for more detail.
      #   The type of this field is +String+.
      # expiration_minutes::
      #   Set the expiration for the one-time passcode, in minutes. The minimum expiration is 1 minute and the maximum is 10 minutes. The default expiration is 2 minutes.
      #   The type of this field is nilable +Integer+.
      # attributes::
      #   Provided attributes to help with fraud detection. These values are pulled and passed into Stytch endpoints by your application.
      #   The type of this field is nilable +Attributes+ (+object+).
      # create_user_as_pending::
      #   Flag for whether or not to save a user as pending vs active in Stytch. Defaults to false.
      #         If true, users will be saved with status pending in Stytch's backend until authenticated.
      #         If false, users will be created as active. An example usage of
      #         a true flag would be to require users to verify their phone by entering the OTP code before creating
      #         an account for them.
      #   The type of this field is nilable +Boolean+.
      # locale::
      #   Used to determine which language to use when sending the user this delivery method. Parameter is a [IETF BCP 47 language tag](https://www.w3.org/International/articles/language-tags/), e.g. `"en"`.
      #
      # Currently supported languages are English (`"en"`), Spanish (`"es"`), French (`"fr"`) and Brazilian Portuguese (`"pt-br"`); if no value is provided, the copy defaults to English.
      #
      # Request support for additional languages [here](https://docs.google.com/forms/d/e/1FAIpQLScZSpAu_m2AmLXRT3F3kap-s_mcV6UTBitYn6CdyWP0-o7YjQ/viewform?usp=sf_link")!
      #
      #   The type of this field is nilable +LoginOrCreateRequestLocale+ (string enum).
      # login_template_id::
      #   Use a custom template for login emails. By default, it will use your default email template. The template must be a template using our built-in customizations or a custom HTML email for Magic links - Login.
      #   The type of this field is nilable +String+.
      # signup_template_id::
      #   Use a custom template for sign-up emails. By default, it will use your default email template. The template must be a template using our built-in customizations or a custom HTML email for Magic links - Sign-up.
      #   The type of this field is nilable +String+.
      #
      # == Returns:
      # An object with the following fields:
      # request_id::
      #   Globally unique UUID that is returned with every API call. This value is important to log for debugging purposes; we may ask for this value to help identify a specific API call when helping you debug an issue.
      #   The type of this field is +String+.
      # user_id::
      #   The unique ID of the affected User.
      #   The type of this field is +String+.
      # email_id::
      #   The unique ID of a specific email address.
      #   The type of this field is +String+.
      # user_created::
      #   In `login_or_create` endpoints, this field indicates whether or not a User was just created.
      #   The type of this field is +Boolean+.
      # status_code::
      #   The HTTP status code of the response. Stytch follows standard HTTP response status code patterns, e.g. 2XX values equate to success, 3XX values are redirects, 4XX are client errors, and 5XX are server errors.
      #   The type of this field is +Integer+.
      def login_or_create(
        email:,
        expiration_minutes: nil,
        attributes: nil,
        create_user_as_pending: nil,
        locale: nil,
        login_template_id: nil,
        signup_template_id: nil
      )
        headers = {}
        request = {
          email: email
        }
        request[:expiration_minutes] = expiration_minutes unless expiration_minutes.nil?
        request[:attributes] = attributes unless attributes.nil?
        request[:create_user_as_pending] = create_user_as_pending unless create_user_as_pending.nil?
        request[:locale] = locale unless locale.nil?
        request[:login_template_id] = login_template_id unless login_template_id.nil?
        request[:signup_template_id] = signup_template_id unless signup_template_id.nil?

        post_request('/v1/otps/email/login_or_create', request, headers)
      end
    end
  end
end
