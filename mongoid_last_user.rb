require 'mongoid'

module MongoidLastUser
  extend ActiveSupport::Concern

  included do
    field :last_user_id
  end
end