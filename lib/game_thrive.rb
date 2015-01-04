require "bundler"
Bundler.setup(:default)

require "faraday"
require "json"
require "logger"
require "active_support/all"

require "game_thrive/version"
require "game_thrive/configuration"
require "game_thrive/response"
require "game_thrive/client"
require "game_thrive/model"
require "game_thrive/player"
require "game_thrive/notification"

module GameThrive

  GAMETHRIVE_URL = "https://gamethrive.com"

  def self.configuration
    @configuration ||= Configuration.new
  end

end
