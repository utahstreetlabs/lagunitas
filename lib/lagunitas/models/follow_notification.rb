require 'lagunitas/models/notification'

class FollowNotification < Notification
  field :follower_id, type: Integer
  validates_presence_of :follower_id
  index :follower_id
end
