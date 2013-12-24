require 'lagunitas/models/listing_notification'

class ListingLikeNotification < ListingNotification
  field :liker_id, type: Integer
  validates_presence_of :liker_id
  index :liker_id
end
