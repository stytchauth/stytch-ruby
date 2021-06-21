# frozen_string_literal: true

module Stytch
  module RequestHelper
    def get_request(path)
      @connection.get(
        path
      ).body
    end

    def post_request(path, payload)
      @connection.post(
        path,
        payload
      ).body
    end

    def put_request(path, payload)
      @connection.put(
        path,
        payload
      ).body
    end

    def delete_request(path)
      @connection.delete(
        path
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
