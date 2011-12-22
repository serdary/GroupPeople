#
# Creating People Groups Using Genetic Algorithms (By Their Similar Interests) 
# Copyright (c) 2011 Serdar Yildirim [me@serdaryildirim.com]
#

# Used to test GroupPeople class
# Main responsibilities are creating a new GroupPeople object with defined CONSTANT values
# and displaying output nicely to provide some information about generations to the user
require './group_people'
class GroupPeopleTest
  INTEREST_COUNT = 10
  PEOPLE_COUNT = 20
  MAX_INTEREST_COUNT_FOR_PERSON = 5
  
  # A static method that creates GroupPeople object and runs the GroupPeople method to generate new generations.
  def self.run
    start_time = Time.now
    puts "Program started at: #{start_time}."
    
    # Create sample interests
    self.create_interests
    interest_created_time = Time.now 
    puts "Interests created in #{interest_created_time - start_time} seconds."
    #puts @interests
    
    # Create sample people with some random interests
    self.create_people 
    people_created_time = Time.now 
    puts "People created in #{people_created_time - interest_created_time} seconds."
    #puts @people
    
    # Group these people using Genetic Algorithm
    gp = GroupPeople.new(@people)
    gp.run
    end_time = Time.now
    
    puts "Groups are created in #{end_time - people_created_time} seconds."
    puts "Program finished in #{end_time - start_time} seconds."
  end
  
  # Creates dummy interests
  def self.create_interests
    @interests = []
    INTEREST_COUNT.times do |i|
      @interests << Interest.new(i+1, "I-#{i+1}")
    end
  end
  
  # Creates dummy people
  def self.create_people
    @people = []
    
    PEOPLE_COUNT.times do |i|
      interests = []
      cloned_interests = @interests.clone
      
      MAX_INTEREST_COUNT_FOR_PERSON.times do |ind| 
        interests << cloned_interests.delete_at(Random.rand(INTEREST_COUNT-ind))
      end
      @people << Person.new(i+1, "P-#{i+1}", interests)
    end
  end
end