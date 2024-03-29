require 'lagunitas/resource/base'

module Lagunitas
  # The root resource.
  class Root < Resource::Base
    # Deletes everything in the entire database. Think three times before you call this!
    def self.nuke
      fire_delete('/')
    end
  end
end
