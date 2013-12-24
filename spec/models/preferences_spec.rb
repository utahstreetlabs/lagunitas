require 'spec_helper'
require 'lagunitas/models/preferences'
require 'json/patch'

describe Preferences do
  let!(:prefs) { FactoryGirl.create(:preferences, user_id: 44444) }

  it "fails to create multiple prefs for a user" do
    expect { FactoryGirl.create(:preferences, user_id: prefs.user_id) }.to raise_error(Mongoid::Errors::Validations)
  end

  it "returns prefs for multiple users" do
    new_user_id = 55555
    ids = [prefs.user_id, new_user_id]
    p = Preferences.find_or_create_by_user_ids(ids)
    p.should include(prefs.user_id => prefs)
    p.should include(new_user_id)
  end
end
