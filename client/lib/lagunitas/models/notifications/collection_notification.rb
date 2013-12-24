require 'lagunitas/models/notification'

module Lagunitas
  class CollectionNotification < Notification
    attr_accessor :collection_id
  end
end
