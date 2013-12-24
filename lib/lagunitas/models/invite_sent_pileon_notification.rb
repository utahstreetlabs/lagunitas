require 'lagunitas/models/notification'

class InviteSentPileOnNotification < Notification
  field :inviter_id, type: Integer
  validates_presence_of :inviter_id
  index :inviter_id

  # the profile that was invited
  field :invitee_profile_id, type: BSON::ObjectId
  validates_presence_of :invitee_profile_id
  index :invitee_profile_id
end
