class Notification
  include Mongoid::Document
  include Mongoid::Timestamps

  index :created_at

  field :user_id, type: Integer
  validates_presence_of :user_id
  index :user_id

  field :viewed_at, type: DateTime

  scope :reverse_chron, order_by([:created_at, :desc])

  def serializable_hash(*args)
    h = super
    h['_id'] = id.to_s
    h['_type'] = _type
    h
  end

  # @option options [Boolean] :mark_viewed (false) whether or not to mark unviewed results as viewed
  def self.for_user(id, options = {})
    scope = user_scope(self, id)
    scope = scope.page(options[:page]) if options[:page]
    scope = scope.per(options[:per]) if options[:per]
    if options[:mark_viewed]
      ids = scope.map(&:id)
      write_scope = any_in(_id: ids)
      write_scope = viewed_scope(write_scope, viewed: false)
      write_scope.update_all(viewed_at: Time.now.utc)
    end
    scope.reverse_chron
  end

  def self.find_unviewed_for_user(id)
    viewed_scope(user_scope(self, id), viewed: false)
  end

  def self.count_unviewed_for_user(id)
    find_unviewed_for_user(id).count
  end

  def self.find_viewed_for_user(id, options = {})
    viewed_scope(user_scope(self, id), options.merge(viewed: true))
  end

  def self.mark_all_viewed_for_user(id)
    viewed_scope(user_scope(self, id), viewed: false).update_all(viewed_at: Time.now.utc)
  end

  def self.delete_viewed_for_user(id, options = {})
    find_viewed_for_user(id, options).delete_all # no callbacks to fire
  end

  def self.delete_viewed(options = {})
    viewed_scope(self, options.merge(viewed: true)).delete_all # no callbacks to fire
  end

  # Maps a type such as +:OrderShippedNotification+ to a notification class (eg +OrderShippedNotification+) and creates
  # an instance of that class, passing +attrs+ to the +create!+ call. Returns the instance.
  #
  # Raises +NameError+ if the type can't be mapped to a notification class. Tries the type name appended with
  # "Notification", if that fails, tries the type name directly.
  def self.create_as_type!(type, attrs)
    clazz = nil
    begin
      clazz = "#{type}Notification".classify.constantize
    rescue NameError
      begin
        clazz = type.to_s.classify.constantize
      rescue NameError
        raise UnknownNotificationType.new(type.to_s)
      end
    end
    clazz.send(:create!, attrs)
  end

  class UnknownNotificationType < Exception; end

  protected
    def self.user_scope(scope, id)
      scope.where(user_id: id)
    end

    def self.viewed_scope(scope, options = {})
      if options[:before]
        scope.where(:viewed_at.lte => options[:before])
      elsif !!options[:viewed]
        scope.excludes(viewed_at: nil)
      else
        scope.where(viewed_at: nil)
      end
    end
end
