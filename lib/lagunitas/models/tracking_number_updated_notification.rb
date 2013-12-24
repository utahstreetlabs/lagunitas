class TrackingNumberUpdatedNotification < Notification
  field :shipment_id, type: Integer
  validates_presence_of :shipment_id
  index :shipment_id

  field :tracking_number, type: String
  validates_presence_of :tracking_number
  index :tracking_number
end
