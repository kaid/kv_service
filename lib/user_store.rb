require "securerandom"

class UserStore
  include Mongoid::Document
  include Mongoid::Timestamps

  field :secret, type: String
  field :uid,    type: String
  field :name,   type: String
  field :email,  type: String
  field :avatar, type: String

  has_many :scopes

  before_save do
    self.generate_secret! if !self.secret
  end

  def scope(scope_name = nil)
    self.scopes.find_or_initialize_by(name: scope_name)
  end

  def generate_secret!
    self.secret = SecureRandom.hex(16)
  end
end
