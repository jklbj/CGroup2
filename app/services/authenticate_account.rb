# frozen_string_literal: true

module CGroup2
  # Find account and check password
  class AuthenticateAccount
    # Error for invalid credentials
    class UnauthorizedError < StandardError
      def initialize(msg = nil)
        @credentials = msg
      end
  
      def message
        "Invalid Credentials for: #{@credentials[:name]}"
      end
    end

    def self.call(credentials)
      account = Account.first(name: credentials[:name])
      unless account.password?(credentials[:password])
        raise(UnauthorizedError, credentials)
      end

      account_and_token(account)
    rescue StandardError
      raise(UnauthorizedError, credentials)
    end

    def self.account_and_token(account)
      {
        type: 'authenticated_account',
        attributes: {
          account: account,
          auth_token: AuthToken.create(account)
        }
      }
    end
  end
end
  