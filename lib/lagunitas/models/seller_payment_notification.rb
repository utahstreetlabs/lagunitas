require 'lagunitas/models/notification'

class SellerPaymentNotification < Notification
  field :payment_id, type: Integer
  validates_presence_of :payment_id
  index :payment_id
end
