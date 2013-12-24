require 'spec_helper'
require 'lagunitas/models/notification'
require 'lagunitas/models/order_shipped_notification'

describe Notification do
  context 'with existing notifications' do
    let!(:n1) { FactoryGirl.create(:notification, user_id: 1, created_at: 1.day.ago) }
    let!(:n2) { FactoryGirl.create(:notification, user_id: 1, created_at: 2.days.ago) }
    let!(:n3) { FactoryGirl.create(:notification, user_id: 2, created_at: 3.days.ago) }

    describe '#for_user' do
      it "returns the user's notifications without marking them viewed" do
        pa = Notification.for_user(1, page: 2, per: 1)
        # use temps to issue the count and find queries only once, otherwise every assertion will re-issue them
        count = pa.total_count
        results = pa.to_a
        count.should == 2
        results.should have(1).notification
        results.first.should == n2
        n1.reload
        n1.viewed_at.should_not be
        n2.reload
        n2.viewed_at.should_not be
      end

      it "returns the user's notifications, marking them viewed" do
        Notification.for_user(1, page: 1, mark_viewed: true)
        n1.reload
        n1.viewed_at.should be
        n2.reload
        n2.viewed_at.should be
      end
    end

    describe '#mark_all_viewed_for_user' do
      it 'marks all unviewed notifications as viewed' do
        expect(Notification.count_unviewed_for_user(1)).to eq(2)
        Notification.mark_all_viewed_for_user(1)
        expect(Notification.count_unviewed_for_user(1)).to eq(0)
      end
    end
  end

  it "creates a notification of a known type" do
    notification = Notification.create_as_type!(:OrderShippedNotification, user_id: 123, order_id: 456)
    notification.should be_a(OrderShippedNotification)
  end

  it "raises an exception when creating a notification of an unknown type" do
    expect { Notification.create_as_type!(:foo, user_id: 123, order_id: 456) }.
      to raise_error(Notification::UnknownNotificationType)
  end
end
