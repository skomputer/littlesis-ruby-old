require 'active_record'
require 'mongoid'
require './config.rb'
require './node.rb'
require './edge.rb'
require 'pry'

ActiveRecord::Base.pluralize_table_names = false

class Entity < ActiveRecord::Base

  def migrate_to_mongo
    raise "can't create mongo data from unpersisted data" if id.nil?
    create_node
    create_sources
    create_images
  end

  def create_node
    return false unless node.nil?

    hash = all_attributes
    old_id = hash["id"]
    hash.delete("id")
    node = Node.new(hash)
    node.old_id = old_id
    node.types = extension_names
    node.save

    @node = node
  end
  
  def node
    @node ||= Node.where(old_id: id).first unless id.nil?
  end
  
  def create_sources
    raise "can't create sources before creating node" if node.nil?
    Reference.where(:object_model => "Entity", :object_id => id).each do |ref|      
      node.sources.create(name: ref.name, url: ref.source) unless node.has_source_url? ref.source
    end
  end
  
  def create_images
  end
    
  def all_attributes
    hash = attributes.merge!(extension_attributes).reject { |k,v| v.nil? }
    hash.delete(:notes)
    hash
  end
  
  def extension_attributes
    hash = {}
    (extension_names & self.class.all_extension_names_with_fields).each do |name|
      ext = Kernel.const_get(name).where(:entity_id => id).first
      ext_hash = ext.attributes
      ext_hash.delete("id")
      ext_hash.delete("entity_id")
      hash.merge!(ext_hash)
    end
    hash
  end

  def extension_ids
    ExtensionRecord.select(:definition_id).where(:entity_id => id).collect { |er| er.definition_id }
  end
  
  def extension_names
    extension_ids.collect { |id| self.class.all_extension_names[id] }
  end
  
  def self.all_extension_names    
    [
      'None',
      'Person',
      'Org',
      'PoliticalCandidate',
      'ElectedRepresentative',
      'Business',
      'GovernmentBody',
      'School',
      'MembershipOrg',
      'Philanthropy',
      'NonProfit',
      'PoliticalFundraising',
      'PrivateCompany',
      'PublicCompany',
      'IndustryTrade',
      'LawFirm',
      'LobbyingFirm',
      'PublicRelationsFirm',
      'IndividualCampaignCommittee',
      'Pac',
      'OtherCampaignCommittee',
      'MediaOrg',
      'ThinkTank',
      'Cultural',
      'SocialClub',
      'ProfessionalAssociation',
      'PoliticalParty',
      'LaborUnion',
      'Gse',
      'BusinessPerson',
      'Lobbyist',
      'Academic',
      'MediaPersonality',
      'ConsultingFirm',
      'PublicIntellectual',
      'PublicOfficial',
      'Lawyer'
    ]
  end
  
  def self.all_extension_names_with_fields
    [
      'Person',
      'Org',
      'PoliticalCandidate',
      'ElectedRepresentative',
      'Business',
      'School',
      'PublicCompany',
      'GovernmentBody',
      'BusinessPerson',
      'Lobbyist',
      'PoliticalFundraising'
    ]
  end
end

class Relationship < ActiveRecord::Base; end
class Link < ActiveRecord::Base

  def migrate_to_mongo
    create_edges
    create_sources
  end

  def create_edges
    return false unless edge.nil?

    create_edges
  end
  
  def create_edges
    create_edge(1)
    create_edge(2)
    edge1.reverse_of = edge2._id
    edge1.save
    edge2.reverse_of = edge1._id
    edge2.save
  end
  
  def create_edge(num)
    other = ([1, 2] - [num]).first
    hash = all_attributes
    hash["node_id"] = hash["entity#{num}_id"]
    hash.delete("entity#{num}_id")
    hash["related_id"] = hash["entity#{other}_id"]
    hash.delete("entity#{other}_id")
    hash["description"] = hash["description#{num}"]
    hash.delete("description#{num}")
    hash.delete("description#{other}")
    old_id = hash["id"]
    hash.delete("id")
    edge = Edge.new(hash)
    edge.old_id = old_id
    edge.category = category_name
    edge.save
    set_instance_variable("@edge#{num}".to_sym, edge)
  end
  
  def edge1
    @edge1 ||= Edge.where(old_id: id, node_id: entity1_id).first unless id.nil?
  end
  
  def edge2
    @edge2 ||= Edge.where(old_id: id, node_id: entity2_id).first unless id.nil?
  end
  
  def create_sources
    raise "can't create sources before creating node" if edge.nil?
    Reference.where(:object_model => "Relationship", :object_id => id).each do |ref|      
      edge1.sources.create(name: ref.name, url: ref.source) unless edge1.has_source_url? ref.source
      edge2.sources.create(name: ref.name, url: ref.source) unless edge2.has_source_url? ref.source
    end
  end

  def self.all_categories
    [
      "",
      "Position",
      "Education",
      "Membership",
      "Family",
      "Donation",
      "Transaction",
      "Lobbying",
      "Social",
      "Professional",
      "Ownership"  
    ]
  end

  def self.all_categories_with_fields
    [
      "Position",
      "Education",
      "Membership",
      "Donation",
      "Transaction",
      "Ownership"
    ]
  end

  def category_name
    self.class.all_categories[category_id]
  end
  
  def all_attributes
    hash = attributes.merge!(category_attributes).reject { |k,v| v.nil? }
    hash.delete("notes")
    hash
  end

  def category_attributes
    return nil unless category_name & self.class.all_categories_with_fields
    category = Kernel.const_get(category_name).where(relationship_id: id).first
    hash = category.attributes
    hash.delete("id")
    hash.delete("relationship_id")
    hash
  end
end

class Reference < ActiveRecord::Base; end

class LsNote < ActiveRecord::Base
  def self.table_name
    'note'
  end
end

# EXTENSION CLASSES
class ExtensionRecord < ActiveRecord::Base; end
class ExtensionDefintion < ActiveRecord::Base; end
class Person < ActiveRecord::Base; end
class Org < ActiveRecord::Base; end
class PoliticalCandidate < ActiveRecord::Base; end
class ElectedRepresentative < ActiveRecord::Base; end
class Business < ActiveRecord::Base; end
class School < ActiveRecord::Base; end
class PublicCompany < ActiveRecord::Base; end
class GovernmentBody < ActiveRecord::Base; end
class BusinessPerson < ActiveRecord::Base; end
class Lobbyist < ActiveRecord::Base; end
class PoliticalFundraising < ActiveRecord::Base; end

# THIS SHOULD BE THE LAST LINE
# ActiveRecord::Base.pluralize_table_names = true