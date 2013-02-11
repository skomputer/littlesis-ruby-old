class User
  include Mongoid::Document
  include Mongoid::Timestamps  
  include Mongoid::Paranoia
  
  belongs_to :note

  field :name
  field :email
  field :old_id, type: Integer
end