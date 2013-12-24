require 'spec_helper'
require 'lagunitas/models/credit_trigger'

describe Lagunitas::CreditTrigger do
  it "finds triggers for a user" do
    user_id = 123
    params = {}
    url = Lagunitas::CreditTriggers.user_triggers_url(user_id)
    data = {'triggers' => [{'_id' => 'deadbeef', '_type' => 'CreditTrigger'}]}
    Lagunitas::CreditTriggers.expects(:fire_get).with(url, has_entry(params: params)).returns(data)
    triggers = Lagunitas::CreditTrigger.find_for_user(user_id, params)
    triggers.should have(1).trigger
    triggers.first.should be_a(Lagunitas::CreditTrigger)
  end

  it "creates a trigger" do
    type = :Signup
    user_id = 123
    attrs = {credit_id: 345}
    url = Lagunitas::CreditTriggers.user_triggers_url(user_id)
    data = {'_id' => 'cafebebe', '_type' => 'SignupCreditTrigger', 'user_id' => user_id, 'credit_id' => 345}
    Lagunitas::CreditTriggers.expects(:fire_post).with(url, has_entries(type: type, attrs: attrs)).returns(data)
    trigger = Lagunitas::CreditTrigger.create(type, user_id, 345, attrs)
    trigger.should be_a(Lagunitas::SignupCreditTrigger)
  end
end
