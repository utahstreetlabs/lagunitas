require 'spec_helper'
require 'rack/test'
require 'lagunitas/apps/preferences'

describe Lagunitas::PreferencesApp do
  include Rack::Test::Methods

  def app
    Lagunitas::PreferencesApp
  end

  context "GET /preferences" do
    let!(:prefs1) { FactoryGirl.create(:preferences, user_id: 55555) }
    let!(:prefs2) { FactoryGirl.create(:preferences, user_id: 66666) }

    it "returns multiple users' preferences" do
      user_ids = [prefs1.user_id, prefs2.user_id]
      get "/preferences", :'id[]' => user_ids
      last_response.status.should == 200
      user_ids.each do |user_id|
        last_response.body.should =~ /#{user_id}/
      end
    end

    it "autocreates missing preferences" do
      user_ids = [77777, 88888, 99999]
      get "/preferences", :'id[]' => user_ids
      last_response.status.should == 200
      user_ids.each do |user_id|
        last_response.body.should =~ /#{user_id}/
      end
    end
  end

  context "GET /users/:id/preferences" do
    it "returns a single user's preferences" do
      prefs = FactoryGirl.create(:preferences, user_id: 55555)
      get "/users/#{prefs.user_id}/preferences"
      last_response.status.should == 200
      last_response.body.should =~ /#{prefs.user_id}/
    end

    it "autocreates missing preferences" do
      user_id = 77777
      get "/users/#{user_id}/preferences"
      last_response.status.should == 200
      last_response.body.should =~ /#{user_id}/
    end
  end

  context "PATCH /users/:id/preferences" do
    let(:user_id) { 55555 }
    let(:blacklist_id) { 12345 }

    it 'updates existing preferences' do
      prefs = FactoryGirl.create(:preferences, user_id: user_id)
      patch_preferences
      last_response.status.should == 200
      preferences_should_be_updated
    end

    it 'autocreates missing preferences' do
      patch_preferences
      preferences_should_be_updated
    end

    it 'fails with a 400 if no patch is given' do
      patch "/users/#{user_id}/preferences", nil
      last_response.status.should == 400
    end

    it 'fails with a 422 if patch application fails' do
      patch "/users/#{user_id}/preferences", %Q<[{"add": "/some_field_that_doesnt_exist", "value": #{blacklist_id}}]>
      last_response.body.should_not =~ /#{blacklist_id}/
      last_response.status.should == 422
    end

    it 'fails with a 400 if the patch is malformed' do
      patch "/users/#{user_id}/preferences", %Q<[{"value": #{blacklist_id}}]>
      last_response.body.should_not =~ /#{blacklist_id}/
      last_response.status.should == 400
    end

    def preferences_should_be_updated
      last_response.body.should =~ /#{blacklist_id}/
      Preferences.where(user_id: user_id).first.follow_suggestion_blacklist.should == [blacklist_id]
    end

    def patch_preferences
      patch "/users/#{user_id}/preferences", %Q<[{"add": "/follow_suggestion_blacklist", "value": #{blacklist_id}}]>
    end
  end

  context "DELETE /users/:id/preferences" do
    it "deletes some preferences" do
      prefs = FactoryGirl.create(:preferences)
      delete "/users/#{prefs.user_id}/preferences"
      last_response.status.should == 204
      Preferences.where(user_id: prefs.user_id).should have(:no).preferences
    end
  end
end
