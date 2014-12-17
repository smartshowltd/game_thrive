module Gamethrive

  class Client

    class NoRestAPIKeyError < StandardError; end
    class RedirectedError < StandardError; end
    class BadRequestError < StandardError; end
    class NotFoundError < StandardError; end
    class InternalServerError < StandardError; end
    class UnknownError < StandardError; end

    attr_accessor :connection

    def initialize
      unless Gamethrive.configuration.rest_api_key
        raise NoRestAPIKeyError, "Rest API key must be provided"
      end

      self.connection = Faraday.new(:url => Gamethrive::GAMETHRIVE_URL) do |faraday|
        faraday.request  :url_encoded # form-encode POST params
        faraday.response :logger, Gamethrive.configuration.logger
        faraday.adapter  :net_http  # make requests with Net::HTTP
        faraday.authorization :Basic, Gamethrive.configuration.rest_api_key
      end
    end

    def dispatch(verb, path, params = nil, body = nil)
      response = connection.send(verb) do |request|
        request.url       build_path(path)
        request.headers = self.headers

        if params
          request.params = params
        end

        if body && %w(post put patch).include?(verb.to_s)
          request.body = json_encode(body)
          Gamethrive.configuration.logger.debug "Body: " + request.body
        end
      end

      Gamethrive.configuration.logger.debug response.inspect

      handle_response(response)
    end


    %w(get post put head delete patch).each do |verb|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.#{verb}(path, params = nil, body = nil)
          request = new
          request.dispatch(:#{verb}, path, params, body)
        end
      RUBY
    end

    protected

    def headers
      {
        "Accept"        => "application/json",
        "Content-Type"  => "application/json",
        "User-Agent"    => Gamethrive.configuration.user_agent
      }
    end

    def handle_response(faraday_response)
      case faraday_response.status
      when 200, 201

        response = Gamethrive::Response.new
        response.request  = self
        response.status   = faraday_response.status
        response.raw_body = faraday_response.body

        response

      when 302
        raise RedirectedError, "Redirected"
      when 400
        raise BadRequestError, "Bad Request"
      when 404
        raise NotFoundError, "Not Found"
      when 500
        raise InternalServerError, "Internal Server Error"
      else
        raise UnknownError, "Response: #{faraday_response.inspect}"
      end
    end

    def json_encode(body)
      JSON.dump(body)
    end

    def build_path(path)
      Gamethrive.configuration.api_base_path + path
    end

  end

end