require 'spec_helper'
require 'rack/test'
require 'lagunitas/apps/notifications'

describe Lagunitas::NotificationsApp do
  include Rack::Test::Methods

  def app
    Lagunitas::NotificationsApp
  end

  context "DELETE /notifications/viewed" do
    let!(:unviewed_notification) { FactoryGirl.create(:notification) }
    let!(:viewed_notifications) do
      1.upto(3).map { |n| FactoryGirl.create(:notification, viewed_at: n.hours.ago) }
    end

    context "without before timestamp" do
      it "deletes all the viewed notifications" do
        delete "/notifications/viewed"
        last_response.status.should == 204
        Notification.count.should == 1
      end
    end

    context "with before timestamp" do
      it "deletes the notifications viewed before that time" do
        delete "/notifications/viewed", b4: 90.minutes.ago.to_i.to_s
        last_response.status.should == 204
        Notification.count.should == 2
      end
    end

    context "with bogus before timestamp" do
      it "deletes no notifications" do
        delete "/notifications/viewed", b4: 'foobar'
        last_response.status.should == 400
        Notification.count.should == 4
      end
    end
  end

  context "GET /users/:id/notifications" do
    let(:user_id) { 55555 }
    let(:total) { 3 }
    let!(:notifications) do
      total.times.map { |n| FactoryGirl.create(:notification, user_id: user_id, created_at: n.days.ago) }
    end

    it "returns a paginated result" do
      get "/users/#{user_id}/notifications", per: '1'
      last_response.status.should == 200
      last_response.json[:total].should == 3
      last_response.json[:results].should have(1).notification
      last_response.json[:results].first['_id'].should == notifications.first.id.to_s
      Notification.count_unviewed_for_user(user_id).should == total
    end

    it "marks returned notifications viewed" do
      get "/users/#{user_id}/notifications", mv: '1'
      last_response.status.should == 200
      Notification.count_unviewed_for_user(user_id).should == 0
    end
  end

  context "POST /users/:id/notifications" do
    let(:user_id) { 55555 }

    context "fails" do
      it "without a type" do
        post "/users/#{user_id}/notifications", %Q/{"attrs":{}}/
        last_response.status.should == 400
        last_response.body.should =~ /type is required/
      end

      it "without attrs" do
        post "/users/#{user_id}/notifications", %Q/{"type":"Notification"}/
        last_response.status.should == 400
        last_response.body.should =~ /attrs is required/
      end

      it "with a bogus type" do
        post "/users/#{user_id}/notifications", %Q/{"type":"Bogus","attrs":{}}/
        last_response.status.should == 400
        last_response.body.should =~ /unknown notification type Bogus/
      end
    end

    context "succeeds" do
      before { post "/users/#{user_id}/notifications", %Q/{"type":"Notification","attrs":{}}/ }

      it "returning 201" do
        last_response.status.should == 201
      end

      it "creating the notification" do
        last_response.body =~ /"_id":"([^"]+)"/
        Notification.find($1).should be
      end

      it "setting the user id" do
        last_response.body.should =~ /"user_id":#{user_id}/
      end
    end
  end

  context "DELETE /users/:id/notifications" do
    let(:user_id) { 55555 }
    let!(:notifications) { 1.upto(3).map { FactoryGirl.create(:notification, :user_id => user_id) } }

    context "succeeds" do
      before { delete "/users/#{user_id}/notifications" }

      it "returning 204" do
        last_response.status.should == 204
      end

      it "deleting all notifications" do
        Notification.for_user(user_id).should have(0).notifications
      end
    end
  end

  context 'DELETE /users/:id/notifications/unviewedness' do
    let(:user_id) { 666666 }
    let!(:notifications) { (1..3).map { FactoryGirl.create(:notification, user_id: user_id) } }

    before { delete "/users/#{user_id}/notifications/unviewedness" }

    it 'returns 204' do
      expect(last_response.status).to eq(204)
    end

    it 'marks all notifications as viewed' do
      expect(Notification.count_unviewed_for_user(user_id)).to eq(0)
    end
  end

  context "GET /users/:id/notifications/unviewed/count" do
    let(:user_id) { 55555 }
    let(:total) { 3 }
    let!(:notifications) do
      total.times.map { |n| FactoryGirl.create(:notification, user_id: user_id, created_at: n.days.ago) }
    end

    it "returns the count of unviewed results" do
      get "/users/#{user_id}/notifications/unviewed/count"
      last_response.status.should == 200
      last_response.json[:count].should == total
    end
  end

  context "DELETE /users/:id/notifications/viewed" do
    let(:user_id) { 55555 }
    let!(:unviewed_notification) { FactoryGirl.create(:notification, user_id: user_id) }
    let!(:viewed_notifications) do
      1.upto(3).map { |n| FactoryGirl.create(:notification, user_id: user_id, viewed_at: n.hours.ago) }
    end

    context "without before timestamp" do
      it "deletes all of the user's viewed notifications" do
        delete "/users/#{user_id}/notifications/viewed"
        last_response.status.should == 204
        Notification.for_user(user_id).should have(1).notification
      end
    end

    context "with before timestamp" do
      it "deletes the user's notifications viewed before that time" do
        delete "/users/#{user_id}/notifications/viewed", b4: 90.minutes.ago.to_i.to_s
        last_response.status.should == 204
        Notification.for_user(user_id).should have(2).notifications
      end
    end

    context "with bogus before timestamp" do
      it "deletes no notifications" do
        delete "/users/#{user_id}/notifications/viewed", b4: 'foobar'
        last_response.status.should == 400
        Notification.for_user(user_id).should have(4).notifications
      end
    end
  end

  context "DELETE /users/:user_id/notifications/:id" do
    let(:notification) { FactoryGirl.create(:notification) }

    context "fails" do
      it "with a bogus user id" do
        delete "/users/#{notification.user_id+1}/notifications/#{notification.id}"
        last_response.status.should == 404
      end
    end

    context "succeeds" do
      before { delete "/users/#{notification.user_id}/notifications/#{notification.id}" }

      it "returning 204" do
        last_response.status.should == 204
      end

      it "deleting the notification" do
        lambda { Notification.find(notification.id) }.should raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end
  end
end
