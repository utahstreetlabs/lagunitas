require 'lagunitas/models/notifications/collection_notification'

module Lagunitas
  class CollectionFollowNotification < CollectionNotification
    attr_accessor :follower_id
  end
end
