require 'lagunitas/models/collection_notification'

class CollectionFollowNotification < CollectionNotification
  field :follower_id, type: Integer
  validates_presence_of :follower_id
  index :follower_id
end
