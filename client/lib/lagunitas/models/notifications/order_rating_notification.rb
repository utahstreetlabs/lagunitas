require 'lagunitas/models/notification'

module Lagunitas
  class OrderRatingNotification < Notification
    attr_accessor :rating_id
  end
end
