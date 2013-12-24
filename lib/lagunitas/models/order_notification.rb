require 'lagunitas/models/notification'

class OrderNotification < Notification
  field :order_id, type: Integer
  validates_presence_of :order_id
  index :order_id
end
