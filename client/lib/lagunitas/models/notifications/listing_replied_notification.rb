require 'lagunitas/models/notifications/listing_notification'

module Lagunitas
  class ListingRepliedNotification < ListingNotification
    attr_accessor :comment_id, :reply_id, :replier_id, :reply_text
  end
end
