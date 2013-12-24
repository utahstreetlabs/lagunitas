require 'lagunitas/models/notification'

class CreditNotification < Notification
  field :credit_id, type: Integer
  validates_presence_of :credit_id
  index :credit_id
end
