# frozen_string_literal: true

module Stytch
  module RequestHelper
    def get_request(path, headers)
      @connection.get(
        path,
        headers
      ).body
    end

    def post_request(path, payload, headers)
      @connection.post(
        path,
        payload,
        headers
      ).body
    end

    def put_request(path, payload, headers)
      @connection.put(
        path,
        payload,
        headers
      ).body
    end

    def delete_request(path, headers)
      @connection.delete(
        path,
        headers
      ).body
    end

    def request_with_query_params(path, params)
      request = path
      params.compact.each_with_index do |p, i|
        request += if i.zero?
                     "?#{p[0]}=#{p[1]}"
                   else
                     "&#{p[0]}=#{p[1]}"
                   end
      end
      request
    end
  end
end
