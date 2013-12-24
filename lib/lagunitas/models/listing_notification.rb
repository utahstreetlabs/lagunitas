require 'lagunitas/models/notification'

class ListingNotification < Notification
  field :listing_id, type: Integer
  validates_presence_of :listing_id
  index :listing_id
end
