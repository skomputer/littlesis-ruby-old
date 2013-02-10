require 'active_record'

ActiveRecord::Base.pluralize_table_names = false

class Entity < ActiveRecord::Base

  def migrate_to_mongo
    create_node
    create_edges
    create_sources
    create_notes
    create_images
  end

  def create_node
    node = Node.new(all_attributes)
    node.types = extension_names
    node.save
  end
  
  def all_attributes
    attributes.merge!(extension_attributes)
  end
  
  def extension_attributes
    hash = {}
    (extension_names & self.class.all_extension_names_with_fields).each do |name|
      ext = Kernel.const_get(name).where(:entity_id => id).first
      ext_hash = ext.attributes
      ext_hash.delete(:id)
      ext_hash.delete(:entity_id)
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

class Reference < ActiveRecord::Base; end

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