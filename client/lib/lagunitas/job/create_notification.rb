require 'ladon/job'
require 'lagunitas/models/notification'

module Lagunitas
  class CreateNotification < Ladon::Job
    @queue = :notification

    def self.work(type, user_id, attrs = {})
      Lagunitas::Notification.create(type, user_id, attrs)
    end
  end
end
