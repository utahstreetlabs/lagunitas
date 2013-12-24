require 'lagunitas/models/notification'

class CollectionNotification < Notification
  field :collection_id, type: Integer
  validates_presence_of :collection_id
  index :collection_id
end
