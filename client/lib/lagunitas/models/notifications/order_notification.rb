require 'lagunitas/models/notification'

module Lagunitas
  class OrderNotification < Notification
    attr_accessor :order_id
  end
end
