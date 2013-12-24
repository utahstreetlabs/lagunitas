require 'lagunitas/models/listing_notification'

class ListingSaveNotification < ListingNotification
  field :saver_id, type: Integer
  validates_presence_of :saver_id
  index :saver_id

  # the collection it was saved to
  field :collection_id, type: Integer
  validates_presence_of :collection_id
  index :collection_id
end
