require 'lagunitas/models/listing_notification'

class ListingFlaggedNotification < ListingNotification
  # no extra fields to store beyond user and listing, as we don't identify the flagging user
end
