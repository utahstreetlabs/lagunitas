require 'lagunitas/models/notification'

class OrderRatingNotification < Notification
  field :rating_id, type: Integer
  validates_presence_of :rating_id
  index :rating_id
end
