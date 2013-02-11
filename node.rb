require 'mongoid'
require './mongoid_dates.rb'
require './mongoid_last_user.rb'
require './source.rb'
require './note.rb'
require './edge.rb'

class Node
  include Mongoid::Document
  include Mongoid::Timestamps  
  include Mongoid::Paranoia
  include MongoidDates
  include MongoidLastUser

  field :name, type: String
  field :summary, type: String
  field :types, type: Array
  field :old_id, type: Integer
  
  embeds_many :sources, as: :sourceable
  # has_many :notes, as: :notable
  # has_many :edges

  def has_source_url?(url)
    sources.each { |s| return true if s.url == url }
    return false
  end
end