# frozen_string_literal: true

require 'spec_helper'

class TestRequestHelper
  include Stytch::RequestHelper
end

RSpec.describe Stytch::RequestHelper do
  let(:helper) { TestRequestHelper.new }

  describe '#request_with_query_params' do
    it 'URL encodes query parameters correctly' do
      path = '/v1/b2b/organizations/org123/member'
      params = { email_address: 'user+test@example.com', member_id: 'member123' }
      
      result = helper.request_with_query_params(path, params)
      
      expect(result).to eq('/v1/b2b/organizations/org123/member?email_address=user%2Btest%40example.com&member_id=member123')
    end

    it 'handles empty params' do
      path = '/v1/b2b/organizations/org123'
      params = {}
      
      result = helper.request_with_query_params(path, params)
      
      expect(result).to eq('/v1/b2b/organizations/org123')
    end

    it 'skips nil values' do
      path = '/v1/b2b/organizations/org123/member'
      params = { email_address: 'test@example.com', member_id: nil }
      
      result = helper.request_with_query_params(path, params)
      
      expect(result).to eq('/v1/b2b/organizations/org123/member?email_address=test%40example.com')
    end

    it 'URL encodes special characters in parameter names and values' do
      path = '/test'
      params = { 'param with spaces' => 'value&with=chars' }
      
      result = helper.request_with_query_params(path, params)
      
      expect(result).to eq('/test?param+with+spaces=value%26with%3Dchars')
    end
  end
end