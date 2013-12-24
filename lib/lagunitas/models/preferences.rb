require 'mongoid/patchable'

class Preferences
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Patchable

  index :created_at

  field :user_id, type: Integer
  validates_presence_of :user_id
  validates_uniqueness_of :user_id
  index :user_id

  field :follow_suggestion_blacklist, type: Array, default: []
  field :invite_suggestion_blacklist, type: Array, default: []
  field :email_opt_outs, type: Array, default: [:follower_list]
  field :features_disabled, type: Array, default: []
  field :autoshare_opt_ins, type: Hash, default: {}
  field :never_autoshare, type: Boolean, default: false
  field :privacy, type: Hash, default: {}

  def self.find_or_create_by_user_ids(user_ids)
    existing = where(:user_id.in => user_ids).each_with_object({}) { |p,m| m[p.user_id] = p }
    user_ids.each do |user_id|
      user_id = user_id.to_i
      existing[user_id] = create!(user_id: user_id) unless existing.include?(user_id)
    end
    existing
  end
end
