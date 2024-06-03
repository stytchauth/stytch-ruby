# frozen_string_literal: true

RSpec.describe Stytch::M2M do
  let(:m2m) { Stytch::M2M.new(nil, '') }

  it 'handles basic m2m auth' do
    has = ['read:user', 'write:user']
    needs = ['read:user']

    expect do
      m2m.perform_authorization_check(has_scopes: has, required_scopes: needs)
    end.not_to raise_error
  end

  it 'handles multiple required scopes' do
    has = ['read:users', 'write:users', 'read:books']
    needs = ['read:users', 'read:books']

    expect do
      m2m.perform_authorization_check(has_scopes: has, required_scopes: needs)
    end.not_to raise_error
  end

  it 'handles simple scopes' do
    has = %w[read_users write_users]
    needs = ['read_users']

    expect do
      m2m.perform_authorization_check(has_scopes: has, required_scopes: needs)
    end.not_to raise_error
  end

  it 'handles wildcard resources' do
    has = ['read:*', 'write:*']
    needs = ['read:users']

    expect do
      m2m.perform_authorization_check(has_scopes: has, required_scopes: needs)
    end.not_to raise_error
  end

  it 'raises an exception for missing scopes' do
    has = ['read:users']
    needs = ['write:users']

    expect do
      m2m.perform_authorization_check(has_scopes: has, required_scopes: needs)
    end.to raise_error(Stytch::M2MPermissionError)
  end

  it 'raises an exception for missing scopes with wildcards' do
    has = ['read:users', 'write:*']
    needs = ['delete:books']

    expect do
      m2m.perform_authorization_check(has_scopes: has, required_scopes: needs)
    end.to raise_error(Stytch::M2MPermissionError)
  end
end
