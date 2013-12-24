require 'lagunitas/models/notifications/listing_notification'

module Lagunitas
  class ListingMentionedNotification < ListingNotification
    attr_accessor :comment_id, :commenter_id, :comment_text
  end
end
