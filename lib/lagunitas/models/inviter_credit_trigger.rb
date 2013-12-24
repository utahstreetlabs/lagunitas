require 'lagunitas/models/credit_trigger'

class InviterCreditTrigger < CreditTrigger
  field :invitee_id, type: Integer
  validates_presence_of :invitee_id
  index :invitee_id
end
