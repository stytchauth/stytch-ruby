# frozen_string_literal: true

RSpec.describe Stytch::M2M do
  let(:m2m) { Stytch::M2M.new(nil, '', false) }

  it 'handles basic m2m auth' do
    has = ['read:user', 'write:user']
    needs = ['read:user']

    res = m2m.perform_authorization_check(has_scopes: has, required_scopes: needs)
    expect(res).to eq(true)
  end

  it 'handles multiple required scopes' do
    has = ['read:users', 'write:users', 'read:books']
    needs = ['read:users', 'read:books']

    res = m2m.perform_authorization_check(has_scopes: has, required_scopes: needs)
    expect(res).to eq(true)
  end

  it 'handles simple scopes' do
    has = %w[read_users write_users]
    needs = ['read_users']

    res = m2m.perform_authorization_check(has_scopes: has, required_scopes: needs)
    expect(res).to eq(true)
  end

  it 'handles wildcard resources' do
    has = ['read:*', 'write:*']
    needs = ['read:users']

    res = m2m.perform_authorization_check(has_scopes: has, required_scopes: needs)
    expect(res).to eq(true)
  end

  it 'raises an exception for missing scopes' do
    has = ['read:users']
    needs = ['write:users']

    res = m2m.perform_authorization_check(has_scopes: has, required_scopes: needs)
    expect(res).to eq(false)
  end

  it 'raises an exception for missing scopes with wildcards' do
    has = ['read:users', 'write:*']
    needs = ['delete:books']

    res = m2m.perform_authorization_check(has_scopes: has, required_scopes: needs)
    expect(res).to eq(false)
  end

  it 'has simple scope and wants specific scope' do
    has = ['read']
    needs = ['read:users']

    res = m2m.perform_authorization_check(has_scopes: has, required_scopes: needs)
    expect(res).to eq(false)
  end

  it 'has specific scope and wants simple scope' do
    has = ['read:users']
    needs = ['read']

    res = m2m.perform_authorization_check(has_scopes: has, required_scopes: needs)
    expect(res).to eq(false)
  end
end
