require 'lagunitas/models/notification'

module Lagunitas
  class CreditNotification < Notification
    attr_accessor :credit_id
  end
end
