#
# Creating People Groups Using Genetic Algorithms (By Their Similar Interests) 
# Copyright (c) 2011 Serdar Yildirim [me@serdaryildirim.com]
#

# Used to store a person's properties such as id, name, interests list
class Person
  attr_reader :id, :name, :interests
  attr_accessor :is_added_chromosome
  
  def initialize(id, name, interests)
    @id, @name, @interests = id, name, interests
  end
  
  def to_s
    "Person(#{@id}): #{@name}, Interests: #{@interests.join(', ')}"
  end
end