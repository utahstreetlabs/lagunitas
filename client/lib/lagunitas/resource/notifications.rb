require 'lagunitas/resource/base'

module Lagunitas
  # The resource representing a user's notifications.
  class Notifications < Resource::Base
    def self.notifications_viewed_url
      "/notifications/viewed"
    end

    def self.user_notifications_url(user_id)
      "/users/#{user_id}/notifications"
    end

    def self.user_notifications_unviewedness_url(user_id)
      "/users/#{user_id}/notifications/unviewedness"
    end

    def self.user_notifications_unviewed_count_url(user_id)
      "/users/#{user_id}/notifications/unviewed/count"
    end

    def self.user_notifications_viewed_url(user_id)
      "/users/#{user_id}/notifications/viewed"
    end

    def self.user_notification_url(user_id, id)
      "/users/#{user_id}/notifications/#{id}"
    end
  end
end
