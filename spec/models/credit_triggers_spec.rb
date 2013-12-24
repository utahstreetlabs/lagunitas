require 'spec_helper'
require 'lagunitas/models/credit_trigger'

describe CreditTrigger do
  describe '#get_for_credit' do
    it 'returns the trigger' do
      trigger = FactoryGirl.create(:credit_trigger)
      CreditTrigger.get_for_credit(trigger.credit_id).should == trigger
    end

    it 'raises DocumentNotFound when the trigger does not exist' do
      expect { CreditTrigger.get_for_credit(123) }.to raise_error(Mongoid::Errors::DocumentNotFound)
    end
  end

  it "returns credit triggers for a user" do
    a1 = FactoryGirl.create(:credit_trigger, user_id: 44444, credit_id: 1234)
    a2 = FactoryGirl.create(:credit_trigger, user_id: 44445, credit_id: 3456)
    CreditTrigger.for_user(44444).to_a.should == [a1]
  end
end
