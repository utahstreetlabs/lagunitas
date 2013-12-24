require 'spec_helper'
require 'rack/test'
require 'lagunitas/apps/credit_triggers'

describe Lagunitas::CreditTriggersApp do
  include Rack::Test::Methods

  def app
    Lagunitas::CreditTriggersApp
  end

  context 'GET /credits/:id/trigger' do
    it 'returns 200 when the trigger exists' do
      trigger = FactoryGirl.create(:credit_trigger)
      get "/credits/#{trigger.credit_id}/trigger"
      last_response.status.should == 200
      last_response.json[:_id].should == trigger.id.to_s
    end

    it 'returns 404 when the trigger does not exist' do
      get "/credits/123/trigger"
      last_response.status.should == 404
    end
  end

  context "GET /users/:id/triggers" do
    let(:user_id) { 55555 }
    let!(:triggers) { 1.upto(3).map { FactoryGirl.create(:credit_trigger, :user_id => user_id) } }

    context "succeeds" do
      before { get "/users/#{user_id}/triggers" }

      it "returning 200" do
        last_response.status.should == 200
      end

      it "including the triggers" do
        triggers.each { |c| last_response.body.should =~ /#{c.id}/ }
      end
    end
  end

  context "POST /users/:id/triggers" do
    let(:user_id) { 55555 }

    context "fails" do
      it "without a type" do
        post "/users/#{user_id}/triggers", %Q/{"attrs":{},"credit_id":1}/
        last_response.status.should == 400
        last_response.body.should =~ /type is required/
      end

      it "without attrs" do
        post "/users/#{user_id}/triggers", %Q/{"type":"CreditTrigger","credit_id":1}/
        last_response.status.should == 400
        last_response.body.should =~ /attrs is required/
      end

      it "without credit id" do
        post "/users/#{user_id}/triggers", %Q/{"type":"CreditTrigger","attrs":{}}/
        last_response.status.should == 400
        last_response.body.should =~ /credit_id is required/
      end

      it "with a bogus type" do
        post "/users/#{user_id}/triggers", %Q/{"type":"Bogus","credit_id":1,"attrs":{}}/
        last_response.status.should == 400
        last_response.body.should =~ /unknown trigger type Bogus/
      end
    end

    context "succeeds" do
      before { post "/users/#{user_id}/triggers", %Q/{"type":"CreditTrigger","credit_id":1,"attrs":{}}/ }

      it "returning 201" do
        last_response.status.should == 201
      end

      it "creating the trigger" do
        last_response.body =~ /"_id":"([^"]+)"/
        CreditTrigger.find($1).should be
      end

      it "setting the user id" do
        last_response.body.should =~ /"user_id":#{user_id}/
      end
    end
  end

  context "DELETE /users/:id/triggers" do
    let(:user_id) { 55555 }
    let!(:triggers) { 1.upto(3).map { FactoryGirl.create(:credit_trigger, :user_id => user_id) } }

    context "succeeds" do
      before { delete "/users/#{user_id}/triggers" }

      it "returning 204" do
        last_response.status.should == 204
      end

      it "deleting all credit triggers" do
        CreditTrigger.for_user(user_id).should have(0).triggers
      end
    end
  end
end
