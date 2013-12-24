require 'lagunitas/resource/base'

module Lagunitas
  # The resource representing a user's preferences.
  class PreferencesResource < Resource::Base
    def self.user_preferences_url(user_id, params = {})
      absolute_url("/users/#{user_id}/preferences", params)
    end

    def self.users_preferences_url(user_ids, params = {})
      params = {'id[]' => user_ids}.merge(params)
      absolute_url("/preferences", params: params)
    end
  end
end
