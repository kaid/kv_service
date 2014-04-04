class Scope
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  embeds_many :key_values

  belongs_to :user_store

  def set(key, value)
    record = get_record(key)
    record.value = value;
    record.save
    value
  end

  def get(key)
    get_record(key).value
  end

  private

  def get_record(key)
    self.key_values.find_or_initialize_by(key: key)
  end
end
