class CreditTrigger
  include Mongoid::Document
  include Mongoid::Timestamps

  index :created_at

  field :user_id, type: Integer
  validates_presence_of :user_id
  index :user_id

  field :credit_id, type: Integer
  validates_presence_of :credit_id
  index :credit_id

  scope :for_user, lambda { |id| where(:user_id => id) }

  def serializable_hash(*args)
    h = super
    h['_id'] = id.to_s
    h['_type'] = _type
    h
  end

  def self.get_for_credit(credit_id)
    conditions = {credit_id: credit_id}
    first(conditions: conditions) or
      raise Mongoid::Errors::DocumentNotFound.new(CreditTrigger, conditions)
  end

  # Maps a type such as +:Signup+ to a trigger class (eg +SignupCreditTrigger+) and creates
  # an instance of that class, passing +attrs+ to the +create!+ call. Returns the instance.
  #
  # Raises +NameError+ if the type can't be mapped to an trigger class. Tries the type name appended with
  # "Trigger", if that fails, tries the type name directly.
  def self.create_as_type!(type, attrs)
    clazz = nil
    begin
      clazz = "#{type}CreditTrigger".classify.constantize
    rescue NameError
      clazz = type.to_s.classify.constantize
    end
    clazz.send(:create!, attrs)
  end
end
