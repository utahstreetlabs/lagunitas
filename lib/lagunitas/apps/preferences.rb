require 'dino/base'
require 'dino/mongoid'
require 'lagunitas/models'
require 'json/patch'

module Lagunitas
  class PreferencesApp < Dino::Base
    include Dino::MongoidApp

    get '/preferences' do
      do_get do
        ids = params[:id] || []
        logger.debug("Getting preferences for users #{ids.join(', ')}")
        {preferences: Preferences.find_or_create_by_user_ids(ids)}
      end
    end

    get '/users/:id/preferences' do
      do_get do
        logger.debug("Getting preferences for user #{params[:id]}")
        Preferences.find_or_create_by(user_id: params[:id])
      end
    end

    patch '/users/:id/preferences' do
      do_patch do |entity|
        raise Dino::BadRequest unless entity
        begin
          prefs = Preferences.find_or_create_by(user_id: params[:id])
          if JSON::Patch.new(entity).apply_to(prefs)
            prefs
          else
            raise Dino::UnprocessableEntity
          end
        rescue ArgumentError
          raise Dino::BadRequest
        end
      end
    end

    delete '/users/:id/preferences' do
      do_delete do
        logger.debug("Deleting preferences for user #{params[:id]}")
        Preferences.where(user_id: params[:id]).destroy_all
      end
    end
  end
end
