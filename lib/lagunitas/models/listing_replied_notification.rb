require 'lagunitas/models/listing_notification'

class ListingRepliedNotification < ListingNotification
  field :replier_id, type: Integer
  field :comment_id
  field :reply_id
  field :reply_text
  validates_presence_of :comment_id, :reply_id, :replier_id, :reply_text
end
