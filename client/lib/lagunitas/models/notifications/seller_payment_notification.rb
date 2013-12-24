require 'lagunitas/models/notification'

module Lagunitas
  class SellerPaymentNotification < Notification
    attr_accessor :payment_id
  end
end
