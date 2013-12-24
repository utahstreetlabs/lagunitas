require 'ladon/model'
require 'lagunitas/resource/credit_triggers'

module Lagunitas
  class CreditTrigger < Ladon::Model
    attr_accessor :user_id, :credit_id

    # Returns the trigger associated with this credit, if any.
    #
    # @return [Lagunitas::CreditTrigger], or +nil+ if the trigger does not exist
    def self.get_for_credit(credit_id)
      attrs = CreditTriggers.fire_get(CreditTriggers.credit_trigger_url(credit_id))
      attrs ? new_from_attributes(attrs) : nil
    end

    # Returns the triggers for a user.
    def self.find_for_user(user_id, params = {})
      data = CreditTriggers.fire_get(CreditTriggers.user_triggers_url(user_id), params: params,
        default_data: {'triggers' => []})
      data['triggers'].map {|attrs| CreditTrigger.new_from_attributes(attrs)}
    end

    # Creates and returns a trigger for a user.
    def self.create(type, user_id, credit_id, attrs = {})
      entity = {type: type, credit_id: credit_id, attrs: attrs}
      data = CreditTriggers.fire_post(CreditTriggers.user_triggers_url(user_id), entity)
      data ? CreditTrigger.new_from_attributes(data) : nil
    end

    # Deletes all of the user's credit triggers.
    def self.delete_all_for_user(user_id)
      CreditTriggers.fire_delete(CreditTriggers.user_triggers_url(user_id))
    end

  protected
    def self.trigger_class(type)
      "Lagunitas::#{type}".constantize
    end

    def self.new_from_attributes(attrs = {})
      trigger_class(attrs.delete('_type')).new(attrs)
    end
  end
end

require 'lagunitas/models/credit_triggers/signup_credit_trigger'
require 'lagunitas/models/credit_triggers/invitee_credit_trigger'
require 'lagunitas/models/credit_triggers/inviter_credit_trigger'
