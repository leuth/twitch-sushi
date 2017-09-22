module TwitchSushi
  class Error < StandardError
    class ResponseError < Error
      def initialize(arg, url, status, body)
        super(arg)
        @url = url
        @status = status
        @body = body
      end

      attr_reader :url, :status, :body
    end

    class ClientError < ResponseError
    end

    class ServerError < ResponseError
    end

    class FormatError < ResponseError
    end
  end
end
