#
# Creating People Groups Using Genetic Algorithms (By Their Similar Interests) 
# Copyright (c) 2011 Serdar Yildirim [me@serdaryildirim.com]
#

# Stores chromosome objects and applies some operations on these chromosomes to create better generations
# Provides Selection and Elimination of worst chromosomes methods and 2 helper methods to display population on console
class Population
  attr_accessor :chromosomes
  
  def initialize(pop_size, group_size)
    @chromosomes, @pop_size, @group_size = [], pop_size, group_size
  end
  
  # Generates an initial population
  # Generates new chromosomes as population size
  def generate_initial_population(people)
    @pop_size.times do |chromosome_id|
      chromosome = Chromosome.new(@group_size)
      @chromosomes << chromosome.generate(people, true)
    end
  end
  
  # Used to create new chromosomes by using some techniques such as elitism, crossover and mutation.
  # If elitism is activated, there will be 1 extra chromosome (because of elitist chromosome will also be crossoverred)
  # So, elimination method is called if population size is bigger than the old one and the worst chromosome is eliminated
  # Returns the new population (which will be replaced on GroupPeople class)
  def make_generation(use_elitism_on_chromosomes, crossover_type, mutation_rate, selection_type)
    new_pop = Population.new(@chromosomes.size, @group_size)
    if use_elitism_on_chromosomes
      new_pop.chromosomes << find_best_chromosome
    end
    
    # Flag all chromosomes as they are not crossoverred yet
    @chromosomes.map { |ch| ch.is_crossoverred = false }
    
    # Main loop, runs until all chromosomes are selected and crossoverred
    until all_chromosomes_crossoverred?
      # Find 2 chromosomes that are not crossoverred yet
      begin
        ch1, ch2 = select_parents selection_type
      end until ch1.id != ch2.id
      ch1.is_crossoverred = ch2.is_crossoverred = true
      
      # Crossover ch1 chromosome with ch2 by crossover_type that is defined at GroupPeople class
      offspring = ch1.crossover ch2, crossover_type
      
      # Apply mutation to offsprings if a random number is in mutation_rate range
      offspring[0].mutate if Random.rand(100) < mutation_rate
      offspring[1].mutate if Random.rand(100) < mutation_rate

      # Add new chromosomes to new population
      new_pop.chromosomes += offspring
    end

    # Eliminate the worst chromosome if population size is bigger than the old one
    # (because of the elitist chromosome)
    new_pop.eliminate_worst_chromosome if new_pop.chromosomes.size > @chromosomes.size
    new_pop
  end
  
  # Removes the worst chromosome.
  # If elitism is not activated, this method is supposed to not called anytime
  # First it checks if the elitist chromosome has been duplicated in the population
  # This may occur because of crossover methods.
  def eliminate_worst_chromosome
    # Check if the elitist chromosome is duplicated after crossoverred
    # This may occur if the self object is better than offsprings so self is returned and added to @chromosomes array
    ind = -1
    @chromosomes.each_with_index do |ch, index|
      ind = index if ch.object_id == @chromosomes[0].object_id and index != 0 
    end
    if ind > 0
      @chromosomes.delete_at ind
      return
    end 
    
    min, will_be_deleted = -1, -1
    @chromosomes.each_with_index do |ch, ind|
      if ch.fitness_value < min or min == -1
        will_be_deleted = ind
        min = ch.fitness_value
      end
    end
    
    @chromosomes.delete_at will_be_deleted
  end
  
  # Finds the best chromosome. 
  # Best chromosome is the chromosome with the highest Fitness Value
  def find_best_chromosome
    max, index = 0, -1
    @chromosomes.each_with_index { |ch, ind| index, max = ind, ch.fitness_value if ch.fitness_value > max }
    @chromosomes[index]
  end
  
  # Selects parents, calls the selection method according to the selection type
  def select_parents(selection_type)
    case selection_type
    when 'random'
      apply_random_selection
    when 'rank_selection'
      apply_rank_selection
    end
  end
  
  # Selects 2 random chromosome within chromosomes, and returns these chromosomes
  def apply_random_selection
    unselected = @chromosomes.select{ |ch| ch.is_crossoverred == false }
    return unselected[Random.rand(unselected.size)], unselected[Random.rand(unselected.size)]
  end
  
  # Applies the rank selection method to chromosomes
  # First all unselected chromosomes are sorted according to their fitness values
  # Then calculates the weights for each of chromosomes
  # Last, loops until it finds unselected & different chromosomes by creating a random number
  # and looking the range of the random number
  def apply_rank_selection
    unselected = @chromosomes.select{ |ch| ch.is_crossoverred == false }
      .sort{ |x, y| x.fitness_value <=> y.fitness_value }
      
    unit_percentage = 100.0 / (1..unselected.size).reduce(:+)
    weights = (1..unselected.size).each.collect { |i| i * unit_percentage }
    
    ch1 = ch2 = nil
    until ch1 != nil and ch2 != nil
      rand_number = Random.rand(100)
      ind = unselected.size - 1
      total = 0
      weights.each_with_index do |w, index|
        total += w
        if total > rand_number
          ind = index
          break
        end
      end

      if ch1 == nil
        ch1 = unselected[ind]
      elsif ch2 == nil and ch1 != unselected[ind]
        ch2 = unselected[ind]
      end
    end
    
    return ch1, ch2
  end

  # Used to display chromosomes and people inside them (nicely on console :)
  def display_population(summary = false)
    puts '********************************************************'
    puts "Best Fitness:(#{find_best_chromosome.fitness_value})"
    @chromosomes.each do |ch|
      puts "Chromosome: #{ch.id}-#{ch.object_id} /FITNESS: #{ch.fitness_value}/"
      ch.groups.each do |group|
        if summary
          print "Group: #{group.id} /SIMILARITY: #{group.similarity}/ - People: "
          group.members.each { |member| print "#{member.id}-" }
        else
          puts "Group: #{group.id} /SIMILARITY: #{group.similarity}/ "
          group.members.each { |member| puts member }
        end
        puts
      end
      puts '--------------------------------------------------------'
    end
    puts '********************************************************'
  end

  # Used to display fitness values of chromosomes (nicely on console :)
  def display_chromosomes
    puts '********************************************************'
    best = find_best_chromosome
    puts "BEST: Chromosome: #{best.id}-#{best.object_id} /FITNESS: #{best.fitness_value}/"
    @chromosomes.each { |ch| puts "Chromosome: #{ch.id}-#{ch.object_id} /FITNESS: #{ch.fitness_value}/" }
    puts '********************************************************'
  end
  
  private
  
  # Finds a chromosome inside the population by its id
  def find_chromosome(id)
    @chromosomes.select { |ch| ch.id == id }.first
  end
  
  # Checks if all chromosomes are crosoverred or not
  def all_chromosomes_crossoverred?
    @chromosomes.select{ |ch| ch.is_crossoverred == false }.size < 1
  end
end