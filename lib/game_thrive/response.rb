module GameThrive

  class Response

    # The original request, for debugging
    attr_accessor :request

    # The response status
    attr_accessor :status

    # The raw response body
    attr_accessor :raw_body

    # The parsed response body
    def body
      @body ||= JSON.parse(raw_body)
    end

  end

end