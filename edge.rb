require 'mongoid'
require './mongoid_dates.rb'
require './source.rb'

class Edge
  include Mongoid::Document
  include Mongoid::Timestamps  
  include Mongoid::Paranoia
  include MongoidDates

  field :node_id
  field :related_id
  field :category
  field :description
  field :is_deleted, type: Boolean
  field :reverse_of
  
  embeds_many :sources
  belongs_to :node

  validates_presence_of :node_id, :related_id, :category

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
end