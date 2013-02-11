require 'mongoid'
require './mongoid_dates.rb'
require './mongoid_last_user.rb'
require './source.rb'

class Edge
  include Mongoid::Document
  include Mongoid::Timestamps  
  include MongoidDates
  include MongoidLastUser

  field :node_id
  field :related_id
  field :category
  field :description
  field :reverse_of
  
  embeds_many :sources, as: :sourceable
  belongs_to :node

  def self.valid_categories
    ["Position", "Education", "Membership", "Family", "Donation", "Transaction", 
     "Lobbying", "Social", "Professional", "Ownership"]
  end  

  def display_description
    if description
      description
    else
      default_description
    end
  end
  
  def default_description
    raise "edge without category has no default description"
  end
  
  def related
    Node.find(related_id)
  end
  
  def reverse
    Edge.find(reverse_of)
  end

  def has_source_url?(url)
    sources.each { |s| return true if s.url == url }
    return false
  end
end