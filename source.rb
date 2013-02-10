class Source
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  embedded_in :node

  field :title, type: String
  field :url, type: String
end