require 'lagunitas/models/notification'

module Lagunitas
  class ListingNotification < Notification
    attr_accessor :listing_id
  end
end
