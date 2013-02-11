#!/Users/matthew/.rvm/rubies/ruby-1.9.3-p286/bin/ruby
require './entity.rb'

start = Time.now

entities = Entity.all

entities.each do |e|
  next if Node.where(old_id: e.id).count > 0
  begin
    e.create_node
  rescue StandardError
    p e
    raise
  end
end

rels = Relationship.all

rels.each do |r|
  next if Edge.where(old_id: e.id).count > 0
  r.create_edges
end

p "Time elapsed: #{Time.now - start}\n"
