require 'lagunitas/models/notifications/listing_notification'

module Lagunitas
  class ListingSaveNotification < ListingNotification
    attr_accessor :saver_id, :collection_id
  end
end
