require 'spec_helper'
require 'lagunitas/models/notification'

describe Lagunitas::Notification do
  it "finds the most recent notifications for a user" do
    user_id = 123
    options = {page: 1, per: 25}
    url = Lagunitas::Notifications.user_notifications_url(user_id)
    pa = mock
    Lagunitas::Notifications.expects(:fire_paged_query).with(url, has_entries(options)).returns(pa)
    Lagunitas::Notification.find_most_recent_for_user(user_id, options).should == pa
  end

  it "creates an notification" do
    type = :OrderCompleted
    user_id = 123
    attrs = {listing_id: 456}
    url = Lagunitas::Notifications.user_notifications_url(user_id)
    data = {'_id' => 'cafebebe', '_type' => 'OrderCompletedNotification', 'user_id' => user_id,
            'listing_id' => attrs[:listing_id]}
    Lagunitas::Notifications.expects(:fire_post).with(url, has_entries(type: type, attrs: attrs)).returns(data)
    notification = Lagunitas::Notification.create(type, user_id, attrs)
    notification.should be_a(Lagunitas::OrderCompletedNotification)
  end

  it "does not create an notification when the service request fails" do
    type = :OrderCompleted
    user_id = 123
    attrs = {listing_id: 456}
    url = Lagunitas::Notifications.user_notifications_url(user_id)
    Lagunitas::Notifications.expects(:fire_post).with(url, has_entries(type: type, attrs: attrs)).returns(nil)
    notification = Lagunitas::Notification.create(type, user_id, attrs)
    notification.should be_nil
  end

  it "enqueues a create notification job" do
    type = :ListingActivated
    user_id = 123
    attrs = {listing_id: 456}
    Lagunitas::CreateNotification.expects(:enqueue).with(type, user_id, attrs)
    Lagunitas::Notification.async_create(type, user_id, attrs)
  end

  it "deletes a notification" do
    user_id = 123
    id = 'deadbeef'
    url = Lagunitas::Notifications.user_notification_url(user_id, id)
    Lagunitas::Notifications.expects(:fire_delete).with(url)
    Lagunitas::Notification.delete(user_id, id)
  end

  it "deletes all of a user's notification" do
    user_id = 123
    url = Lagunitas::Notifications.user_notifications_url(user_id)
    Lagunitas::Notifications.expects(:fire_delete).with(url)
    Lagunitas::Notification.delete_all_for_user(user_id)
  end

  describe '::mark_all_viewed_for_user' do
    let(:user_id) { 123 }
    let(:url) { Lagunitas::Notifications.user_notifications_unviewedness_url(user_id) }

    it 'marks all unviewed notifications viewed' do
      Lagunitas::Notifications.expects(:fire_delete).with(url)
      Lagunitas::Notification.mark_all_viewed_for_user(user_id)
    end
  end
end
