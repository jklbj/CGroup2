# frozen_string_literal: true

require 'roda'
require_relative './app'

module CGroup2
  # Web controller for CGroup2 API
  class Api < Roda
    route('auth') do |routing|# rubocop:disable Metrics 
       # All requests in this route require signed requests
      begin
        @request_data = SignedRequest.new(Api.config).parse(request.body.read)
      rescue SignedRequest::VerificationError
        routing.halt '403', { message: 'Must sign request'}.to_json
      end

      routing.on 'register' do
        # POST api/v1/auth/register
        routing.post do 
          reg_data = JsonRequestBody.parse_symbolize(request.body.read)
          VerifyRegistration.new(Api.config, reg_data).call

          response.status = 202
          { message: 'Verification email sent' }.to_json
        rescue VerifyRegistration::InvalidRegistration => e
          routing.halt 400, { message: e.message }.to_json
        rescue StandardError => e
          puts "ERROR VERIFYING REGISTRATION: #{e.inspect}"
          puts e.message
          routing.halt 500
        end
      end

      routing.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        routing.post do
          auth_account = AuthenticateAccount.call(@request_data)
          auth_account.to_json
        rescue AuthenticateAccount::UnauthorizedError => e
          puts [e.class, e.message].join ': '
          routing.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end
    end
  end
end
