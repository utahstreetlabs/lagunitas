require 'lagunitas/models/listing_notification'

class ListingMentionedNotification < ListingNotification
  field :commenter_id, type: Integer
  field :comment_id
  field :comment_text
  validates_presence_of :commenter_id, :comment_id, :comment_text
end
