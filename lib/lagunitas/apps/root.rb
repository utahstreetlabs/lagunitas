require 'dino/base'
require 'dino/mongoid'
require 'lagunitas/version'

module Lagunitas
  class RootApp < Dino::Base
    set :root, File.join(File.dirname(__FILE__), '..', '..', '..')
    set :version_string, "Lagunitas v#{Lagunitas::VERSION}"
    set :mongoid_config, File.expand_path(File.join(settings.root, 'config', 'mongoid.yml'))

    logger.info("Starting #{settings.version_string}")

    include Dino::MongoidApp
    load_mongoid(settings.mongoid_config)

    get '/' do
      settings.version_string
    end

    delete '/' do
      do_delete do
        Notification.destroy_all
        Preferences.destroy_all
        CreditTrigger.destroy_all
      end
    end
  end
end
