# frozen_string_literal: true

module CGroup2
  # Methods for controllers to mixin
  module SecureRequestHelpers
    def secure_request?(routing)
      routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end

    def authenticated_account(headers)
      return nil unless headers['AUTHORIZATION']

      scheme, auth_token = headers['AUTHORIZATION'].split(' ')
      return nil unless scheme.match?(/^Bearer$/i)

      account_payload = AuthToken.payload(auth_token)
      Account.first(name: account_payload['attributes']['name'])
    end
  end
end
