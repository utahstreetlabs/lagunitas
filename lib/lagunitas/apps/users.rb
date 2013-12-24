require 'dino/base'
require 'dino/mongoid'
require 'lagunitas/models'

module Lagunitas
  class UsersApp < Dino::Base
    include Dino::MongoidApp

    delete '/users/:id' do
      do_delete do
        user_id = params[:id].to_i
        logger.debug("Deleting everything for user #{user_id}")
        Notification.for_user(user_id).destroy_all
        CreditTrigger.for_user(user_id).destroy_all
        Preferences.where(user_id: user_id).destroy_all
      end
    end
  end
end
