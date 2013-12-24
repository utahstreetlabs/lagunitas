require 'lagunitas/models/notification'

module Lagunitas
  class TrackingNumberUpdatedNotification < Notification
    attr_accessor :shipment_id, :tracking_number
  end
end
