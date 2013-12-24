require 'rubygems'
require 'bundler'

Bundler.require

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

require 'dino/cascade'
require 'dino/kaminari'
require 'lagunitas/apps/root'
require 'lagunitas/apps/notifications'
require 'lagunitas/apps/preferences'
require 'lagunitas/apps/credit_triggers'
require 'lagunitas/apps/users'

use LogWeasel::Middleware

Kaminari.configure do |config|
  config.default_per_page = 100
end

apps = [
  Lagunitas::NotificationsApp,
  Lagunitas::PreferencesApp,
  Lagunitas::CreditTriggersApp,
  Lagunitas::UsersApp,
  Lagunitas::RootApp
]

run Dino::Cascade.new(*apps)
