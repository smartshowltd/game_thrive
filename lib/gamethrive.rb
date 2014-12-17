require "bundler"
Bundler.setup(:default)

require "faraday"
require "json"
require "logger"
require "active_support/all"

require "gamethrive/version"
require "gamethrive/configuration"
require "gamethrive/response"
require "gamethrive/client"
require "gamethrive/model"
require "gamethrive/player"
require "gamethrive/notification"

module Gamethrive

  GAMETHRIVE_URL = "https://gamethrive.com"

  def self.configuration
    @configuration ||= Configuration.new
  end

end
