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
        if i == 0
          request += "?#{p[0].to_s}=#{p[1]}"
        else
          request += "&#{p[0].to_s}=#{p[1]}"
        end
      end
      request
    end
  end
end
