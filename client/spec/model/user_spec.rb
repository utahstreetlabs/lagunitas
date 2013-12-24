require 'spec_helper'
require 'lagunitas/models/user'

describe Lagunitas::User do
  describe '::destroy' do
    let(:user_id) { 123 }
    it 'deletes a user' do
      Lagunitas::Users.expects(:fire_delete).with(Lagunitas::Users.user_url(user_id))
      Lagunitas::User.destroy(user_id)
    end
  end
end
