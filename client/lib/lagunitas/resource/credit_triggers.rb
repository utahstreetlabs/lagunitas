require 'lagunitas/resource/base'

module Lagunitas
  # The resource representing a user's triggers.
  class CreditTriggers < Resource::Base
    def self.credit_trigger_url(id)
      absolute_url("/credits/#{id}/trigger")
    end

    def self.user_triggers_url(user_id, params = {})
      absolute_url("/users/#{user_id}/triggers", params)
    end
  end
end
