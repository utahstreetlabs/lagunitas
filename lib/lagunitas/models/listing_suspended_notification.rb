require 'lagunitas/models/listing_notification'

class ListingSuspendedNotification < ListingNotification
  # no extra fields to store beyond user and listing, as we don't identify the suspending user
end
