require 'lagunitas/models/notifications/listing_notification'

module Lagunitas
  class ListingLikeNotification < ListingNotification
    attr_accessor :liker_id
  end
end
