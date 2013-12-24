require 'spec_helper'
require 'rack/test'
require 'lagunitas/apps/root'

describe Lagunitas::RootApp do
  include Rack::Test::Methods

  def app
    Lagunitas::RootApp
  end

  context "GET /" do
    it "shows name and version" do
      get '/'
      last_response.body.should =~ /Lagunitas v#{Lagunitas::VERSION}/
    end
  end

  context "DELETE /" do
    let!(:notifications) { 1.upto(3).map { |n| FactoryGirl.create(:notification, :user_id => n) } }

    context "succeeds" do
      before { delete '/' }

      it "returning 204" do
        last_response.status.should == 204
      end

      it "deleting all notifications" do
        Notification.count.should == 0
      end

      it "deleting all preferences" do
        Preferences.count.should == 0
      end

      it "deleting all credit triggers" do
        CreditTrigger.count.should == 0
      end
    end
  end
end
