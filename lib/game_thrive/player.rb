module GameThrive
  class Player < GameThrive::Model

    #
    # Attributes
    # Refer to http://documentation.gamethrive.com/v1.0/docs/players-add-a-device for details
    #

    # String: The player's UUID
    attribute :id

    # String: your GameThrive application key. Required.
    attribute :app_id

    # Integer: 0 = iOS, 1 = Android, 2 = Amazon, 3 = Windows Phone. Required.
    attribute :device_type

    # String: Push notification identifier from Google or Apple
    # When setting, strip all non-alphanumeric characters
    attribute :identifier

    # String: Language code: typically lower case two lettes except for Chinese
    attribute :language

    # Integer: Timezone offset - number of seconds away from UTC, e.g. -28800
    attribute :timezone

    # String: Version of the app
    attribute :game_version

    # String: Device model, i.e. iPhone5,1
    attribute :device_model

    # String: Device operating system version
    attribute :device_os

    # String: Android = Advertising ID, iOS = The identifierForVendor, WP 8.0 =
    # the DeviceUniqueId, WP 8.1 = The AdvertisingId
    attribute :ad_id

    # String: Name and version of the plugin that's calling this API method (if
    # any)
    attribute :sdk

    # Integer: Number of times the user has played the game, defaults to 1
    attribute :session_count

    # Hash: Custom tags (tag and value) for the player
    attribute :tags

    # String: Amount spent in USD, up to two decimal places
    attribute :amount_spent

    # Integer: Unixtime when the player joined the game
    attribute :created_at

    # Integer: Seconds player was running your app
    attribute :playtime

    # Integer: Current iOS badge count displayed on the app icon
    attribute :badge_count

    # Integer: Unixtime when the player was last active
    attribute :last_active

    #
    # Class methods
    #

    def self.create(attributes = {})
      player = new(attributes)
      player.save
    end

    def self.find(id)
      response = GameThrive::Client.get("/players/#{id}")

      player = new(response.body)
      player.reset_changed_attributes!
      player
    end

    def self.on_session!(id, attributes = {})
      raise NotImplementedError, "on_session is not implemented"
    end

    def self.on_purchase!(id, attributes = {})
      raise NotImplementedError, "on_purchase is not implemented"
    end

    def self.on_focus!(id, attributes = {})
      raise NotImplementedError, "on_focus is not implemented"
    end

    def self.list(options = {})
      options = {
        :app_id => nil,
        :limit => 50,
        :offset => 0
      }.merge(options)

      response = GameThrive::Client.get("/players", options)
      response.body["players"].map do |attrs|
        player = new(attrs)
        player.reset_changed_attributes!
        player
      end
    end

    def self.count(options = {})
      options = {
        :app_id => nil,
        :limit  => 1,
        :offset => 0
      }.merge(options)

      response = GameThrive::Client.get("/players", options)
      response.body["total_count"]
    end

    #
    # Instance methods
    #

    def update_attributes(attributes = {})
      assign_attributes(attributes, :reset => false)
      save
    end

    def save
      return if changed_attributes.empty?

      response = if persisted?
        GameThrive::Client.put("/players/#{id}", {}, attributes_for_api)
      else
        GameThrive::Client.post("/players", {}, attributes_for_api)
      end

      # Reset changed attributes after a save. If we receive an error response
      # e.g. Bad Request, then we'll get raise an exception before here.
      reset_changed_attributes!

      response.body
    end

    def persisted?
      id && id.strip != ""
    end

    def reload!
      response = GameThrive::Client.get("/players/#{id}")
      assign_attributes(response.body)
      reset_changed_attributes!

      self
    end

  end
end
