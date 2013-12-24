require 'lagunitas/models/notification'

module Lagunitas
  class FollowNotification < Notification
    attr_accessor :follower_id
  end
end
