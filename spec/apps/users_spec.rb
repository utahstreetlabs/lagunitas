require 'spec_helper'
require 'rack/test'
require 'lagunitas/apps/users'

describe Lagunitas::UsersApp do
  include Rack::Test::Methods

  def app
    Lagunitas::UsersApp
  end

  context 'DELETE /users/:id' do
    let(:user_id) { 12345 }
    let!(:notification) { FactoryGirl.create(:notification, user_id: user_id) }
    let!(:preferences) { FactoryGirl.create(:preferences, user_id: user_id) }
    let!(:credit_trigger) { FactoryGirl.create(:credit_trigger, user_id: user_id) }

    before { delete "/users/#{user_id}" }

    it 'deletes allthethings' do
      expect(last_response.status).to eq(204)
      expect(Notification.for_user(user_id)).to have(0).notifications
      expect(Preferences.where(user_id: user_id)).to have(0).preferenceses
      expect(CreditTrigger.for_user(user_id)).to have(0).triggers
    end
  end
end
