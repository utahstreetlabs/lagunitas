require 'ladon/model'
require 'lagunitas/job/create_notification'
require 'lagunitas/resource/notifications'

module Lagunitas
  class Notification < Ladon::Model
    attr_accessor :user_id

    # @option options [DateTime] :before clear only notifications viewed before this time
    def self.delete_viewed(options = {})
      options = options.dup
      before = options.delete(:before)
      options[:before] = format_timestamp_param(before) if before
      options[:params_map] = {before: :b4}
      Notifications.fire_delete(Notifications.notifications_viewed_url, options)
    end

    # Returns the most recent notifications for a user.
    #
    # @option options [Boolean] +mark_viewed+
    # @return [Ladon::PaginatableArray]
    # @see Lagunitas::Resource::Base#fire_paged_query
    def self.find_most_recent_for_user(user_id, options = {})
      options[:results_mapper] = ->(attrs) { Notification.new_from_attributes(attrs) }
      options[:params_map] = {mark_viewed: :mv}
      Notifications.fire_paged_query(Notifications.user_notifications_url(user_id), options)
    end

    def self.count_unviewed_for_user(user_id)
      Notifications.fire_count_query(Notifications.user_notifications_unviewed_count_url(user_id))
    end

    # @option options [DateTime] :before clear only notifications viewed before this time
    def self.delete_viewed_for_user(user_id, options = {})
      options = options.dup
      before = options.delete(:before)
      options[:before] = format_timestamp_param(before) if before
      options[:params_map] = {before: :b4}
      Notifications.fire_delete(Notifications.user_notifications_viewed_url(user_id), options)
    end

    def self.mark_all_viewed_for_user(user_id)
      Notifications.fire_delete(Notifications.user_notifications_unviewedness_url(user_id))
    end

    # Creates and returns an notification for a user.
    def self.create(type, user_id, attrs = {})
      entity = {type: type, attrs: attrs}
      data = Notifications.fire_post(Notifications.user_notifications_url(user_id), entity)
      data ? Notification.new_from_attributes(data) : nil
    end

    # Enqueues a +CreateNotification+ job to create an notification for a user.
    def self.async_create(type, user_id, attrs = {})
      logger.debug("Enqueuing CreateNotification of type #{type} for user #{user_id} with attrs #{attrs.inspect}")
      Lagunitas::CreateNotification.enqueue(type, user_id, attrs)
    end

    # Deletes the identified notification. Silently fails if the notification does not belong to the identified user.
    def self.delete(user_id, id)
      Notifications.fire_delete(Notifications.user_notification_url(user_id, id))
    end

    # Deletes all of the user's notifications.
    def self.delete_all_for_user(user_id)
      Notifications.fire_delete(Notifications.user_notifications_url(user_id))
    end

  protected
    def self.notification_class(type)
      "Lagunitas::#{type}".constantize
    end

    def self.new_from_attributes(attrs = {})
      notification_class(attrs.delete('_type')).new(attrs)
    end

    def self.format_timestamp_param(value)
      value.utc.to_i if value
    end
  end
end

# load after Notification is defined because subclasses need it to exist
require 'lagunitas/models/notifications/collection_follow_notification'
require 'lagunitas/models/notifications/credit_granted_notification'
require 'lagunitas/models/notifications/feedback_decreased_notification'
require 'lagunitas/models/notifications/feedback_increased_notification'
require 'lagunitas/models/notifications/follow_notification'
require 'lagunitas/models/notifications/invite_sent_pileon_notification'
require 'lagunitas/models/notifications/listing_commented_notification'
require 'lagunitas/models/notifications/listing_like_notification'
require 'lagunitas/models/notifications/listing_flagged_notification'
require 'lagunitas/models/notifications/listing_replied_notification'
require 'lagunitas/models/notifications/listing_mentioned_notification'
require 'lagunitas/models/notifications/listing_save_notification'
require 'lagunitas/models/notifications/listing_suspended_notification'
require 'lagunitas/models/notifications/order_completed_notification'
require 'lagunitas/models/notifications/order_created_notification'
require 'lagunitas/models/notifications/order_delivered_notification'
require 'lagunitas/models/notifications/order_delivery_confirmation_period_elapsed_notification'
require 'lagunitas/models/notifications/order_failed_notification'
require 'lagunitas/models/notifications/order_shipped_notification'
require 'lagunitas/models/notifications/order_unrated_notification'
require 'lagunitas/models/notifications/order_unshipped_notification'
require 'lagunitas/models/notifications/seller_payment_paid_notification'
require 'lagunitas/models/notifications/seller_payment_rejected_notification'
require 'lagunitas/models/notifications/tracking_number_updated_notification'
