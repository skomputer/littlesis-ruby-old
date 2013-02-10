require 'mongoid'
require './mongoid_dates.rb'
require './source.rb'

class Node
  include Mongoid::Document
  include Mongoid::Timestamps  
  include Mongoid::Paranoia
  include MongoidDates

  field :name, type: String
  field :summary, type: String
  field :types, type: Array
  
  embeds_many :sources
  has_many :edges
end