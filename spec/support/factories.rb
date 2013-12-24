require 'lagunitas/models/notification'
require 'lagunitas/models/order_notification'
require 'lagunitas/models/credit_trigger'

FactoryGirl.define do
  factory :notification do
    sequence(:user_id) {|n| n}
  end

  factory :order_notification, :parent => :notification, :class => OrderNotification do
    sequence(:order_id) {|n| n}
  end

  factory :preferences do
    sequence(:user_id) {|n| n}
  end

  factory :credit_trigger do
    sequence(:user_id) {|n| n}
    sequence(:credit_id) {|n| n}
  end
end
