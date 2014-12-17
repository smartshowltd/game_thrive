module Gamethrive
  class Notification < Gamethrive::Model

    #
    # Attributes
    # Reference: http://documentation.gamethrive.com/v1.0/docs/notifications-create-notification
    #

    # General parameters

    # String: Gamethrive notification UUID.
    attribute :id

    # String: Gamethrive application UUID. Required to create notifications.
    attribute :app_id

    # Hash: Contents to send in the message, where keys are two-character language
    # codes and the values are the messages. At least "en" is required to create
    # notifications. Required.
    attribute :contents

    # Hash: Notification titles to send to Android devices. See contents.
    attribute :headings

    # Boolean: Send to iOS devices?
    attribute :is_ios, "isIos"

    # Boolean: Send to Android devices?
    attribute :is_android, "isAndroid"

    # Boolean: Send to Windows Phone devices?
    attribute :is_wp, "isWP"


    # Targeting parameters

    # NOTE: You must not combine targeting parameters unless noted with exception
    # of targeting parameters from the same group.

    # Group: Segments

    # Array: Names of segments to send the message to. Can be used with excluded
    # segments but no other targeting parameters
    attribute :included_segments

    # Array: Names of segments to not send messages to. To be used in
    # conjunction with included_segments
    attribute :excluded_segments

    # Group: Users

    # Array: Specific players to send notifications to
    attribute :include_player_ids

    # Array: Specific iOS device tokens to send the notification to
    attribute :include_ios_tokens

    # Array: Specific Android registration ids (apids) to send notifications to
    attribute :include_android_reg_ids

    # Array: Specific Windows Phone channel UIs to send notifications to
    attribute :include_wp_urls

    # Group: Tags

    # Array: Array of hashes that specify tag predicates. The general pattern is
    # [{"key" => "tagName", :relation => "=", "value" => "comparison value"}, ..]
    # See the API reference for more details and options.
    attribute :tags


    # Notifcation attributes

    # String: Badge change to use for iOS, values are 'None', 'SetTo', or 'Increase'
    attribute :ios_badge_type, "ios_badgeType"

    # Integer: Sets or increases the badge icon on the device depending on the
    # ios_badgetype value
    attribute :ios_badge_count, "ios_badgeCount"

    # String: Sound file to play on iOS when notification is received. The file
    # must be bundled with your app as a resource.
    attribute :ios_sound

    # String: Sound file to play on Android when notification is received. The
    # file must be bundled with your app as a resource. Do not incldue the file
    # extension.
    attribute :android_sound

    # String: Sound file to play on WP when notification is received. The file
    # must be bundled with your app as a resource.
    attribute :wp_sound

    # Hash: Custom key/value data to send to your app
    attribute :data

    # Array: Buttons to add to the notification. Supported on iOS 8.0+ and
    # Android 4.1+. Icon only works for Android. The keys required are 'id',
    # 'text', and 'icon'. Data should be supplied as an array of hashes
    #
    # Example [{:id => "id1", :text => "First button", :icon => "button_icon"}, ..]
    attribute :buttons

    # String: Specific Android icon to use, if blank app icon is used
    attribute :small_icon

    # String: Specific Android icon to display on left of the notification, if
    # blank :small_icon is used.
    attribute :large_icon

    # String: Specific Android picture to display in the expanded view. Can be
    # resource name or URL
    attribute :big_picture

    # String: Specify a URL to have it open in system browser when notification
    # is opened
    attribute :url


    # Scheduling

    # String: Schedule notification for future delivery, example:
    # "Fri May 02 2014 00:00:00 GMT-0700 (PDT)"
    attribute :send_after

    # String: Customise delivery to player/user - possible values are:
    #   "timezone" (delivery at specific time of day in each user's timezone)
    #   "last-active" (deliver same time of day as each user as last active)
    # If :send_after is used, this takes effect after the :send_after time has
    # elapsed
    attribute :delayed_option

    # String: Use this with :delayed_option "timezone", e.g. "9:00 AM"
    attribute :delivery_time_of_day


    # Response attributes

    # The following attributes are populated in responses should not be set
    # when creating or updating notifications.

    attribute :successful
    attribute :failed
    attribute :converted
    attribute :remaining
    attribute :queued_at


    #
    # Class methods
    #

    def self.create(attributes = {})
      notification = new(attributes)
      notification.save
    end

    def self.find(id)
      response = Gamethrive::Client.get("/notifications/#{id}")

      notification = new(response.body)
      notification.reset_changed_attributes!
      notification
    end

    def self.list(options = {})
      options = {
        :app_id => nil,
        :limit  => 50,
        :offset => 0
      }.merge(options)

      response = Gamethrive::Client.get("/notifications", options)

      response.body["notifications"].map do |attrs|
        notification = new(attrs)
        notification.reset_changed_attributes!
        notification
      end
    end

    def self.count(options = {})
      options = {
        :app_id => nil,
        :limit  => 1,
        :offset => 0
      }.merge(options)

      response = Gamethrive::Client.get("/notifications", options)
      response.body["total_count"]
    end

    def track_open!(id)
      raise NotImplementedError, "track_open! is not implemented."
    end

    def delete!(options = {})
      options = { :app_id => app_id }.merge(options)
      Gamethrive::Client.delete("/notifications/#{id}", options)
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
        Gamethrive::Client.put("/notifications/#{id}", {}, attributes_for_api)
      else
        Gamethrive::Client.post("/notifications", {}, attributes_for_api)
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
      response = Gamethrive::Client.get("/notifications/#{id}")
      assign_attributes(response.body)
      reset_changed_attributes!

      self
    end

  end
end
