module GameThrive

  class Configuration

    def self.option(name, default_value)
      attr_accessor name.to_sym
      @@defaults ||= {}
      @@defaults[name] = default_value
    end

    # Options that can be set via GameThrive.configuration are detailed below,
    # with their defaults.

    # To set the :app_id option below, use the following in your app:
    #   `GameThrive.configuration.app_id = "some id"`

    # Your GameThrive app id/key, find this in Application Settings > API Keys
    # in your GameThrive account. This must be set in order to access the API.
    option :app_id, nil

    # Your GameThrive REST API key, also find this in Application Settings >
    # API Keys in your GameThrive account This must be set in order to access
    # the API.
    option :rest_api_key, nil

    # The logger to use for Faraday (HTTP request library)
    default_logger = ::Logger.new(STDOUT)
    default_logger.level = ::Logger::INFO
    option :logger, default_logger

    # User agent to send with requests to the GameThrive API
    option :user_agent, "Ruby #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL} smartshowltd/game_thrive v" + GameThrive::VERSION.to_s

    # Base path to the the API. This is appended to the GameThrive URL.
    option :api_base_path, "/api/v1"

    def initialize
      @@defaults.each do |option, value|
        send "#{option.to_s}=", value
      end
    end
  end

end