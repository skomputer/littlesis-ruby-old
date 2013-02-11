class Note
  include Mongoid::Document
  include Mongoid::Timestamps  
  include Mongoid::Paranoia

  belongs_to :notable, polymorphic: true

  field :body

  has_one :user
  
  validates_presence_of :user_id
end