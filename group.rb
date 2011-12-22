#
# Creating People Groups Using Genetic Algorithms (By Their Similar Interests) 
# Copyright (c) 2011 Serdar Yildirim [me@serdaryildirim.com]
#

# Group class stores Person objects as members, has an id and a similarity property
# To keep up-to-date the overall fitness of the chromosome, 
# Group's similarity should be re-calculated when group member(s) changed 
class Group
  attr_reader :id, :similarity
  attr_accessor :members
  
  def initialize(id)
    @id, @members = id, []
  end
  
  # Calculates the similarity of the group
  # Loops every member inside the group, takes their all interests
  # Creates a hash as -> agg[interest.id] = interest count and calculates an interest's occurence percentage
  # Sums all percentages and find the similarity by dividing that to interest count.
  def calculate_similarity
    agg = {}
    members.each do |m|
      m.interests.each do |int|
        agg[int.id] = (agg.key? int.id) ? agg[int.id] + 1 : 1
      end
    end
    
    total = 0
    agg.map { |k, v| total += (v / members.size.to_f) * 100 }
    @similarity = total / agg.size
    
    self
  end
  
  def to_s
    "Group(#{@id}) /SIM:#{@similarity}/ - members: #{@members.join(', ')}"
  end
end