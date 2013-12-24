require 'lagunitas/resource/base'

module Lagunitas
  class Users < Resource::Base
    def self.user_url(user_id)
      absolute_url("/users/#{user_id}")
    end
  end
end
