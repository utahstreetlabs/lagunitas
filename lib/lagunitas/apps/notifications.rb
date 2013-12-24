require 'dino/base'
require 'dino/mongoid'
require 'lagunitas/apps/pagination'
require 'lagunitas/models'

module Lagunitas
  class NotificationsApp < Dino::Base
    include Dino::MongoidApp
    include Pagination

    delete '/notifications/viewed' do
      do_delete do
        options = {before: parse_datetime_param(:b4)}
        logger.debug("Deleting viewed notifications with options #{options.inspect}")
        Notification.delete_viewed(options)
      end
    end

    get '/users/:id/notifications' do
      do_get do
        mark_viewed = params[:mv] == "1" || params[:mv] == "true"
        options = pagination_params.merge(mark_viewed: mark_viewed)
        logger.debug("Finding notifications for user #{params[:id]} with options #{options.inspect}")
        Notification.for_user(params[:id], options)
      end
    end

    post '/users/:id/notifications' do
      do_post do |entity|
        type = entity['type'] or raise Dino::BadRequest, 'type is required'
        attrs = entity['attrs'] or raise Dino::BadRequest, 'attrs is required'
        begin
          logger.debug("Creating #{type} notification for user #{params[:id]} with attrs #{attrs.inspect}")
          Notification.create_as_type!(type, attrs.merge('user_id' => params[:id]))
        rescue Notification::UnknownNotificationType
          logger.warn("unknown notification type #{type}")
          raise Dino::BadRequest, "unknown notification type #{type}"
        end
      end
    end

    delete '/users/:id/notifications' do
      do_delete do
        logger.debug("Deleting notifications for user #{params[:id]}")
        Notification.for_user(params[:id]).destroy_all
      end
    end

    delete '/users/:id/notifications/unviewedness' do
      do_delete do
        logger.debug("Marking all unviewed notifications as viewed for user #{params[:id]}")
        Notification.mark_all_viewed_for_user(params[:id])
        nil
      end
    end

    get '/users/:id/notifications/unviewed/count' do
      do_get do
        logger.debug("Counting unviewed notifications for user #{params[:id]}")
        {count: Notification.count_unviewed_for_user(params[:id])}
      end
    end

    delete '/users/:id/notifications/viewed' do
      do_delete do
        options = {before: parse_datetime_param(:b4)}
        logger.debug("Deleting viewed notifications for user #{params[:id]} with options #{options.inspect}")
        Notification.delete_viewed_for_user(params[:id], options)
      end
    end

    delete '/users/:user_id/notifications/:id' do
      do_delete do
        notification = Notification.find(params[:id])
        raise Dino::NotFound unless notification.user_id.to_s == params[:user_id]
        logger.debug("Deleting notification #{params[:id]} for user #{params[:user_id]}")
        notification.destroy
      end
    end
  end
end
