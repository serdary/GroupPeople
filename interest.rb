#
# Creating People Groups Using Genetic Algorithms (By Their Similar Interests) 
# Copyright (c) 2011 Serdar Yildirim [me@serdaryildirim.com]
#

# A simple class to store interest id and name for an interest object
class Interest
  attr_reader :id, :name
  
  def initialize(id, name)
    @id, @name = id, name
  end
  
  def to_s
    #"Interest(#{@id}): #{@name}"
    @name
  end
end