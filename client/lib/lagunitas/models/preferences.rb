require 'ladon/model'
require 'lagunitas/resource/preferences'

module Lagunitas
  class Preferences < Ladon::Model
    attr_accessor :user_id, :invite_suggestion_blacklist, :follow_suggestion_blacklist, :email_opt_outs,
      :features_disabled, :autoshare_opt_ins, :never_autoshare, :privacy

    def initialize(attrs = {})
      super(attrs)
      @invite_suggestion_blacklist = [] unless invite_suggestion_blacklist
      @follow_suggestion_blacklist = [] unless follow_suggestion_blacklist
      @features_disabled = [] unless features_disabled
      @autoshare_opt_ins = {} unless autoshare_opt_ins
      fixup_privacy
    end

    # Saves the user's email opt-out preferences. +params+ is a hash of email symbols and flags. For each symbol, if its
    # flag is +true+, then an opt-out is recorded, otherwise that opt-out is removed.
    def save_email_opt_outs(params = {})
      patch = params.stringify_keys.each_with_object([]) do |kv, m|
        op = kv.last == true ? :add : :remove
        m << {op => '/email_opt_outs', value: kv.first}
      end
      data = PreferencesResource.fire_patch(PreferencesResource.user_preferences_url(user_id), patch)
      data ? self.class.new(data) : nil
    end

    # Saves the user's disabled features preferences. +params+ is a hash of feature symbols and flags.
    # For each symbol, if its flag is +true+, then the feature is recorded, otherwise the feature is removed.
    def save_features_disabled(params = {})
      patch = params.stringify_keys.each_with_object([]) do |kv, m|
        op = kv.last == true ? :add : :remove
        m << {op => '/features_disabled', value: kv.first}
      end
      data = PreferencesResource.fire_patch(PreferencesResource.user_preferences_url(user_id), patch)
      data ? self.class.new(data) : nil
    end

    # Saves the user's autoshare opt-ins for a network. +events+ is a list of events to autoshare for that network.
    def save_autoshare_opt_ins(network, events)
      patch = [{replace: "/autoshare_opt_ins", value: "#{network}[]=#{events.join(',')}"}]
      data = PreferencesResource.fire_patch(PreferencesResource.user_preferences_url(user_id), patch)
      data ? self.class.new(data) : nil
    end

    def save_never_autoshare(value)
      patch = [{replace: "/never_autoshare", value: value}]
      data = PreferencesResource.fire_patch(PreferencesResource.user_preferences_url(user_id), patch)
      data ? self.class.new(data) : nil
    end

    # Returns true if the user opts into autosharing this event to this network.
    def allow_autoshare?(network, event)
      autoshare_opt_ins.has_key?(network.to_s) ? autoshare_opt_ins[network.to_s].include?(event.to_s) : false
    end

    def allow_autoshare!(network, event)
      set_autoshare_opt_in_pref!(network, event, :add)
    end

    def disallow_autoshare!(network, event)
      set_autoshare_opt_in_pref!(network, event, :delete)
    end

    def allow_email?(key)
      email_opt_outs and !email_opt_outs.include?(key.to_s)
    end

    # @param [Hash (Symbol => Boolean)] prefs
    # @return [Lagunitas::Preferences] an updated set of preferences, or nil if there was an error
    def save_privacy(prefs)
      patch = prefs.each_with_object([]) do |(key, value), m|
        m << {replace: '/privacy', value: "#{key}=#{value}"}
      end
      data = PreferencesResource.fire_patch(PreferencesResource.user_preferences_url(user_id), patch)
      data ? self.class.new(data) : nil
    end

    # Returns whether or not the indicated preference has been explicitly stated to be private. Defaults to +false+
    # unless the server requested failed, in which case we return +true+ to protect the user's privacy in absence of
    # any indication one way or the other.
    #
    # @param [Symbol] pref the preference key
    # @option options [Lagunitas::Preferences] :preferences
    # @return [Boolean]
    def private?(key)
      privacy ? privacy.fetch(key, false) : true
    end

    # Returns preferences documents for one or more users. When +user_id+ is specified as an +Enumerable+, returns a
    # hash of +Preference+s keyed on user id; otherwise, returns a single +Preferences+ for that particular user.
    def self.find(user_ids, options = {})
      params = options.fetch(:params, {})
      if user_ids.is_a?(Enumerable)
        batch_size = options.fetch(:batch_size, 100)
        hashes = user_ids.each_slice(batch_size).map do |u|
          url = PreferencesResource.users_preferences_url(user_ids, params)
          data = PreferencesResource.fire_get(url, default_data: {'preferences' => {}})
          data['preferences'].each_with_object({}) { |(key, val), m| m[key.to_i] = new(val) }
        end
        hashes.reduce { |m, h| m.merge(h) }
      else
        url = PreferencesResource.user_preferences_url(user_ids, params)
        new(PreferencesResource.fire_get(url, default_data: {}))
      end
    end

    # Sets an attribute or adds a value to a list
    def self.add(user_id, attr, value)
      data = PreferencesResource.fire_patch(
        PreferencesResource.user_preferences_url(user_id), [{add: "/#{attr}", value: value}])
      data ? new(data) : nil
    end

    protected

    def set_autoshare_opt_in_pref!(network, event, op)
      events = (self.autoshare_opt_ins[network] || []).to_set
      events.send(op, event.to_s)
      self.save_autoshare_opt_ins(network, events.to_a)
    end

    def fixup_privacy
      # it's very important that privacy remain nil if not in the provided attrs - that's how we distinguish between
      # a prefs object that represents a failed find request (nil) and one that represents a blank set of privacy prefs
      # (empty hash)
      if privacy
        # the current implementation of json-patch doesn't know how to cast hash values to booleans, so privacy values
        # wind up being saved as "true" and "false". cast them back to their proper types.
        self.privacy = privacy.each_with_object({}) do |(key, value), m|
          value = true if value == 'true'
          value = false if value == 'false'
          m[key.to_sym] = value
        end
      end
    end
  end
end
