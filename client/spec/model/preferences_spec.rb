require 'spec_helper'
require 'lagunitas/models/preferences'

describe Lagunitas::Preferences do
  let(:user_id) { 1 }

  describe "#save_email_opt_outs" do
    let(:email) { 'follow_me' }

    it "adds an opt-out" do
      url = Lagunitas::PreferencesResource.user_preferences_url(user_id)
      Lagunitas::PreferencesResource.expects(:fire_patch).with(url, [{add: "/email_opt_outs", value: email}]).
        returns({email_opt_outs: [email]})
      subject = Lagunitas::Preferences.new(user_id: user_id)
      updated = subject.save_email_opt_outs(email => true)
      updated.email_opt_outs.should == [email]
    end

    it "removes an opt-out" do
      url = Lagunitas::PreferencesResource.user_preferences_url(user_id)
      Lagunitas::PreferencesResource.expects(:fire_patch).with(url, [{remove: "/email_opt_outs", value: email}]).
        returns({email_opt_outs: []})
      subject = Lagunitas::Preferences.new(user_id: user_id)
      updated = subject.save_email_opt_outs(email => false)
      updated.email_opt_outs.should be_empty
    end
  end

  describe "#save_features_disabled" do
    let(:feature) { 'request_timeline_facebook' }

    it "adds an option" do
      url = Lagunitas::PreferencesResource.user_preferences_url(user_id)
      Lagunitas::PreferencesResource.expects(:fire_patch).with(url, [{add: "/features_disabled", value: feature}]).
        returns({features_disabled: [feature]})
      subject = Lagunitas::Preferences.new(user_id: user_id)
      updated = subject.save_features_disabled(feature => true)
      updated.features_disabled.should == [feature]
    end

    it "removes an option" do
      url = Lagunitas::PreferencesResource.user_preferences_url(user_id)
      Lagunitas::PreferencesResource.expects(:fire_patch).with(url, [{remove: "/features_disabled", value: feature}]).
        returns({features_disabled: []})
      subject = Lagunitas::Preferences.new(user_id: user_id)
      updated = subject.save_features_disabled(feature => false)
      updated.features_disabled.should be_empty
    end
  end

  describe "#save_autoshare_opt_ins" do
    let(:event) { :listing_liked }
    let(:network) { :facebook }

    it "replaces a network opt-in" do
      url = Lagunitas::PreferencesResource.user_preferences_url(user_id)
      Lagunitas::PreferencesResource.expects(:fire_patch).with(url, [{replace: "/autoshare_opt_ins",
        value: "#{network}[]=#{event}"}]).returns({autoshare_opt_ins: {network => [event]}})
      subject = Lagunitas::Preferences.new(user_id: user_id)
      updated = subject.save_autoshare_opt_ins(network, [event])
      updated.autoshare_opt_ins[network].should == [event]
    end
  end

  describe "#allow_autoshare?" do
    let(:event) { :listing_liked }
    let(:network) { :facebook }

    it "allows autoshareing" do
      subject.autoshare_opt_ins[network.to_s] = [event.to_s]
      subject.allow_autoshare?(network, event).should be_true
    end

    it "disallows autoshareing when it has no opt-ins for the network" do
      subject.allow_autoshare?(network, event).should be_false
    end

    it "disallows autoshareing when it does not opt in to the event for the network" do
      subject.autoshare_opt_ins[:facebook] = []
      subject.allow_autoshare?(network, event).should be_false
    end
  end

  describe "autoshare methods" do
    let(:opt_ins) { {} }
    let(:network) { :friendster }
    subject { Lagunitas::Preferences.new(autoshare_opt_ins: opt_ins ) }

    describe "allow_autoshare!" do
      it "saves an opt-in" do
        subject.expects(:save_autoshare_opt_ins).with(network, ['listing_activated']).returns({})
        subject.allow_autoshare!(network,'listing_activated')
      end

      context "with an existing opt-in" do
        let(:opt_ins) { {network => ['ham_sausages']} }
        it "preserves existing opt-ins" do
          subject.expects(:save_autoshare_opt_ins).with(network, ['ham_sausages', 'listing_activated']).returns({})
          subject.allow_autoshare!(network,'listing_activated')
        end
      end
    end

    describe "disallow_autoshare!" do
      context "with an existing opt-in" do
        let(:opt_ins) { {network => ['listing_activated']} }
        it "saves an opt-out" do
          subject.expects(:save_autoshare_opt_ins).with(network, []).returns({})
          subject.disallow_autoshare!(network,'listing_activated')
        end
      end

      context "with two existing opt-ins" do
        let(:opt_ins) { {network => ['ham_sausages', 'listing_activated']} }
        it "preserves existing opt-ins" do
          subject.expects(:save_autoshare_opt_ins).with(network, ['ham_sausages']).returns({})
          subject.disallow_autoshare!(network,'listing_activated')
        end
      end
    end
  end

  describe "#allow_email?" do
    let(:opt_outs) { [] }
    subject { Lagunitas::Preferences.new(email_opt_outs: opt_outs) }

    it "returns true when email not disabled" do
      subject.allow_email?(:hams).should be_true
    end

    context "when opt_outs is nil" do
      let(:opt_outs) { ["hams"] }
      it "returns false" do
        subject.allow_email?(:hams).should be_false
      end
    end

    context "when opt_outs is nil (eg, because of a timeout)" do
      let(:opt_outs) { nil }
      it "returns false" do
        subject.allow_email?(:hams).should be_false
      end
    end
  end

  describe '.private?' do
    context 'when there are no privacy prefs' do
      it 'defaults to true' do
        subject.private?(:foo).should be_true
      end
    end

    context 'when the pref has no value' do
      before { subject.privacy = {} }

      it 'defaults to false' do
        subject.private?(:foo).should be_false
      end
    end

    context 'when the pref has a false value' do
      before { subject.privacy = {foo: false} }

      it 'returns the value' do
        subject.private?(:foo).should be_false
      end
    end

    context 'when the pref has a true value' do
      before { subject.privacy = {foo: true} }

      it 'returns the value' do
        subject.private?(:foo).should be_true
      end
    end
  end

  describe "#find" do
    it "returns prefs for a single user" do
      user_id = 123
      url = Lagunitas::PreferencesResource.user_preferences_url(user_id)
      attrs = {}
      Lagunitas::PreferencesResource.expects(:fire_get).with(url, has_key(:default_data)).returns(attrs)
      preferences = Lagunitas::Preferences.find(user_id)
      preferences.should be_a(Lagunitas::Preferences)
    end

    it "returns prefs for multiple users" do
      user_ids = [123, 456, 789]
      url = Lagunitas::PreferencesResource.users_preferences_url(user_ids)
      attrs = user_ids.inject({}) {|m, i| m.merge!(i => {})}
      Lagunitas::PreferencesResource.expects(:fire_get).with(url, has_key(:default_data)).
        returns({'preferences' => attrs})
      preferences = Lagunitas::Preferences.find(user_ids)
      preferences.should have(user_ids.size).preferences
    end

    it "fetches preferences in batches" do
      ids = 1..100
      Lagunitas::PreferencesResource.expects(:fire_get).times(10).
        returns({'preferences' => {1 => {}, 2 => {}}})
      r = Lagunitas::Preferences.find(ids, batch_size: 10)
      r.should be_an_instance_of(Hash)
      r.count.should == 2
      r.should have_key(2)
      r.should have_key(1)
    end
  end

  describe "#add" do
    let(:blacklisted) { 123 }

    it "fires a patch request" do
      url = Lagunitas::PreferencesResource.user_preferences_url(user_id)
      Lagunitas::PreferencesResource.expects(:fire_patch).
        with(url, [{add: "/follow_suggestion_blacklist", value: blacklisted}]).once.
        returns({follow_suggestion_blacklist: [blacklisted]})
      preferences = Lagunitas::Preferences.add(user_id, :follow_suggestion_blacklist, blacklisted)
      preferences.follow_suggestion_blacklist.should == [blacklisted]
    end
  end

  describe '.fixup_privacy' do
    context 'when there are no privacy prefs' do
      before { subject.send(:fixup_privacy) }
      its(:privacy) { should be_nil }
    end

    context 'when there are privacy prefs' do
      let(:preferences) { Lagunitas::Preferences.new }
      before do
        preferences.privacy = {foo: 'true', bar: 'false', baz: true, quux: false}
        preferences.send(:fixup_privacy)
      end
      subject { preferences.privacy }
      its([:foo]) { should be_true }
      its([:bar]) { should be_false }
      its([:baz]) { should be_true }
      its([:quux]) { should be_false }
    end
  end
end
