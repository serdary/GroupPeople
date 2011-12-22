#
# Creating People Groups Using Genetic Algorithms (By Their Similar Interests) 
# Copyright (c) 2011 Serdar Yildirim [me@serdaryildirim.com]
#

# Contains groups as GENES. Groups contains people objects.
# Different types of crossover methods and mutation methods included.
# Chromosome has also a TEMPORARY class variable as @@autoId. 
# This is because chromosomes are not stored in somewhere (not yet),
# like DB, so this class variable is needed to provide an auto id property.
class Chromosome
  attr_reader :groups, :group_size, :fitness_value
  attr_accessor :id, :is_crossoverred
  @@autoId = 1
  
  # Initializes a new chromosome by an id and empty groups
  def initialize(group_size)
    @group_size, @groups = group_size, []
    
    @id = @@autoId
    @@autoId += 1
  end
  
  # Generates a new chromosome randomly or sequentially.
  # Random is used while creating initial chromosomes to test the chromosomes and population
  # Chromosome contains lots of groups that groups includes people inside.
  # So this method generates groups, add people to groups, calculates groups' similarity
  # and lastly it calculates chromosomes' fitness value
  def generate(people, is_random = false)
    people.map { |p| p.is_added_chromosome = false }
    
    group_id = 1
    group = Group.new(group_id)
    
    # Loop as people size, create new group objects, add person to group objects and calculate the group similarity
    people.size.times do |i|
      begin
        person = is_random ? people[Random.rand(people.size)] : people[i]
      end until person.is_added_chromosome == false
      person.is_added_chromosome = true
      
      group.members << person
      
      if (i+1) % @group_size == 0
        @groups << group.calculate_similarity
        group_id += 1
        group = Group.new(group_id)
      end
    end
    @chromosome_size = @group_size * @groups.size
    
    calculate_fitness
    self
  end
  
  # Applies crossover according to crossover type
  # After creating 2 offsprings, there will be 4 chromosomes, method sorts according to
  # similarity percentages and returns the best 2 chromosomes.
  def crossover(ch2, type)
    case type
      when '1point'
        ch1_people, ch2_people = apply_crossover_1point ch2
      when '2point'
        ch1_people, ch2_people = apply_crossover_2point ch2
      when 'uniform'
        ch1_people, ch2_people = apply_crossover_uniform ch2
    end
    
    offspring1 = Chromosome.new(@group_size).generate(ch1_people)
    offspring2 = Chromosome.new(@group_size).generate(ch2_people)
    return [self, ch2, offspring1, offspring2].sort{ |x, y| y.fitness_value <=> x.fitness_value }.first(2)
  end
  
  # Applies mutation to the chromosome
  # Chooses two random person inside chromosomes, and changes their placements (group)
  def mutate
    random_ind1 = Random.rand(@chromosome_size)
    random_ind2 = Random.rand(@chromosome_size)
    group_ind1 = person_ind1 = group_ind2 = person_ind2 = 0
    @groups.each_with_index do |group, group_index|
      group.members.each_with_index do |person, person_index|
        if (group_index * @group_size + person_index) == random_ind1
          group_ind1, person_ind1 = group_index, person_index
        elsif (group_index * @group_size + person_index) == random_ind2
          group_ind2, person_ind2 = group_index, person_index
        end
      end
    end
    
    @groups[group_ind1].members[person_ind1], @groups[group_ind2].members[person_ind2] = 
      @groups[group_ind2].members[person_ind2], @groups[group_ind1].members[person_ind1]
    
    # Calculate the similarities of the effected groups and fitness value of the chromosome
    @groups[group_ind1].calculate_similarity
    @groups[group_ind2].calculate_similarity
    calculate_fitness
  end
  
  def to_s
    "Chromosome(#{@id}) /FITNESS: #{@fitness_value}/ : Groups:#{@groups.join(', ')}"
  end
  
  private
  # Calculates the fitness value of the chromosome
  # Sums each group's similarity value, divides the total number to group count
  def calculate_fitness
    total_similarity = 0
    @groups.map { |g| total_similarity += g.similarity }
    @fitness_value = total_similarity / @groups.size
  end
  
  # Applies 1 point crossover to chromosomes
  # Finds the middle point of the chromosome, takes the first part of chromosome1 and
  # takes missing people from chromosome2 and creates another offsping by remaining people
  # Returns newly created 2 list of people to create two new offspring chromosomes on wrapper method
  def apply_crossover_1point(ch2)
    mid_point = @chromosome_size / 2
    
    # Select first half of the 1st chrom to the 1st chromosome and second half to the 2nd chromosome
    # i.e. : ch1:1011 -> offspring1: 10__ - offspring2: 11__
    ch1_people, ch2_people, person_ind = [], [], 0
    @groups.each do |group|
      group.members.each do |person|
        if person_ind < mid_point
          ch1_people << person
        else
          ch2_people << person
        end
        person_ind += 1
      end
    end
    
    # Now, take the missing persons to the first chromosome, and place the remaining chromosomes to the second new chromosome
    return add_missing_genes_to_lists ch2, ch1_people, ch2_people
  end
  
  # Applies 2 point crossover to the chromosomes
  # Chooses a random point on parent chromosome1 and another point which needs to bigger than random point 1
  # Takes the people until first random point and after second random point to the offspring1
  # Takes remaining people from parent chromosome2
  # Takes the people between random point1 and random point2 and takes remaining from parent chromosome2
  # Returns newly created 2 list of people to create two new offspring chromosomes on wrapper method
  def apply_crossover_2point(ch2)
    point1 = Random.rand(@chromosome_size / 2)
    point2 = point1 + Random.rand((@chromosome_size/2)-1)
    
    # Select 0-point1 genes to 1st offspring, point1-point2 genes to 2nd offspring
    # and point2-@chromosome-size genes to 1st offspring.
    # i.e.: ch1: 123456 p1:2 p2: 4 -> offspring1: 12__56 offspring2: __34__
    ch1_people, ch2_people, person_ind = [], [], 0
    @groups.each do |group|
      group.members.each do |person|
        if person_ind < point1 or person_ind > point2
          ch1_people << person
        else
          ch2_people << person
        end
        person_ind += 1
      end
    end
    
    # Now, take the missing persons to the first chromosome
    # Place the remaining chromosomes to the second new chromosome
    return add_missing_genes_to_lists ch2, ch1_people, ch2_people
  end
  
  # Applies uniform crossover type to the chromosomes
  # Takes even index persons of parent chromosome1 to offspring1, and places even index persons to offspring2
  # Adds the remaining parts of the people lists of chromosomes
  # Returns newly created 2 list of people to create two new offspring chromosomes on wrapper method
  def apply_crossover_uniform(ch2)    
    ch1_people, ch2_people, person_ind = [], [], 0
    @groups.each do |group|
      group.members.each do |person|
        if person_ind % 2 == 0
          ch1_people << person
        else
          ch2_people << person
        end
        person_ind += 1
      end
    end
    
    return add_missing_genes_to_lists ch2, ch1_people, ch2_people
  end
  
  # Adds missing genes (persons) to the lists.
  # Loops parent chromosome2 and checks person is included in list 1, if so it adds person to list 2
  # otherwise it adds person to list1. After all persons on parent chromosome2 is examined, altered lists are returned
  def add_missing_genes_to_lists(ch2, ch1_people, ch2_people)
    ch2.groups.each do |group|
      group.members.each do |person|
        if (ch1_people.size < @chromosome_size and (! ch1_people.include? person))
          ch1_people << person
        else
          ch2_people << person
        end
      end
    end
    return ch1_people, ch2_people
  end
end