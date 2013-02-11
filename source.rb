class Source
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  embedded_in :sourceable, polymorphic: true

  field :name, type: String
  field :url, type: String
end