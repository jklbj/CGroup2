# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaboratorToProject service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      CGroup2::Account.create(account_data)
    end
  end

  it 'HAPPY: should authenticate valid account credentials' do
    credentials = DATA[:accounts].first
    account = CGroup2::AuthenticateAccount.call(
      name: credentials['name'], password: credentials['password']
    )
    _(account).wont_be_nil
  end

  it 'SAD: will not authenticate with invalid password' do
    credentials = DATA[:accounts].first
    proc {
      CGroup2::AuthenticateAccount.call(
        name: credentials['name'], password: 'malword'
      )
    }.must_raise CGroup2::AuthenticateAccount::UnauthorizedError
  end

  it 'BAD: will not authenticate with invalid credentials' do
    proc {
      CGroup2::AuthenticateAccount.call(
        name: 'maluser', password: 'malword'
      )
    }.must_raise CGroup2::AuthenticateAccount::UnauthorizedError
  end
end
