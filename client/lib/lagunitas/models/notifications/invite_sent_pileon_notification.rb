require 'lagunitas/models/notification'

module Lagunitas
  class InviteSentPileOnNotification < Notification
    attr_accessor :inviter_id
    attr_accessor :invitee_profile_id
  end
end
